package main

import (
	"bufio"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"
)

const (
	proofTraceGenesis = "GENESIS"
	defaultProofTrace = ".kb/trace.jsonl"
)

type ProofCheck struct {
	Kind      string   `json:"kind"`
	Target    []string `json:"target"`
	Expect    any      `json:"expect,omitempty"`
	TimeoutMS int      `json:"timeout_ms,omitempty"`
}

type ProofSenseResult struct {
	OK          bool   `json:"ok"`
	CheckDigest string `json:"check_digest"`
	Signal      string `json:"signal"`
	Evidence    string `json:"evidence"`
}

type ProofTraceEvent struct {
	Version     int    `json:"version"`
	Time        string `json:"time"`
	Tool        string `json:"tool"`
	CheckDigest string `json:"check_digest"`
	OK          bool   `json:"ok"`
	Signal      string `json:"signal"`
	Evidence    string `json:"evidence"`
	PrevHash    string `json:"prev_hash"`
	Hash        string `json:"hash"`
}

type ProofTraceVerify struct {
	OK       bool   `json:"ok"`
	Rows     int    `json:"rows"`
	HeadHash string `json:"head_hash"`
	BrokenAt *int   `json:"broken_at"`
	Reason   string `json:"reason,omitempty"`
}

type ProofGateResult struct {
	OK              bool   `json:"ok"`
	CheckDigest     string `json:"check_digest"`
	TraceIntact     bool   `json:"trace_intact"`
	SawRed          bool   `json:"saw_red"`
	GreenAfterRed   bool   `json:"green_after_red"`
	CurrentlyGreen  bool   `json:"currently_green"`
	CurrentSignal   string `json:"current_signal"`
	CurrentEvidence string `json:"current_evidence"`
	Reason          string `json:"reason"`
}

func runProofSenseCommand(root string, opts options, stdout, stderr io.Writer) int {
	check, err := loadProofCheck(resolveInputPath(root, opts.checkPath))
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	digest, err := proofCheckDigest(root, check)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	result := proofSense(root, check)
	result.CheckDigest = digest
	tracePath := resolveProofTracePath(root, opts.tracePath)
	if _, err := appendProofTrace(tracePath, "sense", digest, result.OK, result.Signal, result.Evidence); err != nil {
		fmt.Fprintf(stderr, "append trace: %v\n", err)
		return 1
	}
	writeProofJSON(stdout, result)
	if !result.OK {
		return 1
	}
	return 0
}

func runProofTraceVerifyCommand(root string, opts options, stdout, stderr io.Writer) int {
	result, err := verifyProofTrace(resolveProofTracePath(root, opts.tracePath))
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	writeProofJSON(stdout, result)
	if !result.OK {
		return 1
	}
	return 0
}

func runProofAcceptCommand(root string, opts options, stdout, stderr io.Writer) int {
	check, err := loadProofCheck(resolveInputPath(root, opts.checkPath))
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	result, err := proofAccept(root, resolveProofTracePath(root, opts.tracePath), check)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	writeProofJSON(stdout, result)
	if !result.OK {
		return 1
	}
	return 0
}

func loadProofCheck(path string) (ProofCheck, error) {
	content, err := os.ReadFile(path)
	if err != nil {
		return ProofCheck{}, fmt.Errorf("read check: %w", err)
	}
	var raw struct {
		Kind      string          `json:"kind"`
		Target    json.RawMessage `json:"target"`
		Expect    any             `json:"expect,omitempty"`
		TimeoutMS int             `json:"timeout_ms,omitempty"`
	}
	if err := json.Unmarshal(content, &raw); err != nil {
		return ProofCheck{}, fmt.Errorf("parse check: %w", err)
	}
	target, err := decodeProofTarget(raw.Target)
	if err != nil {
		return ProofCheck{}, err
	}
	return ProofCheck{Kind: raw.Kind, Target: target, Expect: raw.Expect, TimeoutMS: raw.TimeoutMS}, nil
}

func decodeProofTarget(raw json.RawMessage) ([]string, error) {
	if len(raw) == 0 || string(raw) == "null" {
		return nil, fmt.Errorf("check target is required")
	}
	var one string
	if err := json.Unmarshal(raw, &one); err == nil {
		if strings.TrimSpace(one) == "" {
			return nil, fmt.Errorf("check target cannot be empty")
		}
		return []string{one}, nil
	}
	var many []string
	if err := json.Unmarshal(raw, &many); err != nil {
		return nil, fmt.Errorf("check target must be string or string array")
	}
	if len(many) == 0 {
		return nil, fmt.Errorf("check target cannot be empty")
	}
	for _, item := range many {
		if strings.TrimSpace(item) == "" {
			return nil, fmt.Errorf("check target cannot contain empty strings")
		}
	}
	return many, nil
}

func proofSense(root string, check ProofCheck) ProofSenseResult {
	switch strings.ToLower(strings.TrimSpace(check.Kind)) {
	case "command_exit":
		return proofSenseCommand(root, check)
	case "file_sha256":
		return proofSenseFileSHA256(root, check)
	case "regex_in_file":
		return proofSenseRegexInFile(root, check)
	default:
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: "unsupported check kind: " + check.Kind}
	}
}

func proofSenseCommand(root string, check ProofCheck) ProofSenseResult {
	if len(check.Target) == 0 {
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: "command_exit requires target argv"}
	}
	expect, err := proofExpectedExit(check.Expect)
	if err != nil {
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: err.Error()}
	}
	timeout := time.Duration(check.TimeoutMS) * time.Millisecond
	if timeout <= 0 {
		timeout = 30 * time.Second
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, check.Target[0], check.Target[1:]...)
	cmd.Dir = root
	out, err := cmd.CombinedOutput()
	evidence := truncateProofEvidence(string(out))
	if ctx.Err() == context.DeadlineExceeded {
		return ProofSenseResult{OK: false, Signal: "timeout", Evidence: fmt.Sprintf("timed out after %s\n%s", timeout, evidence)}
	}
	exitCode := 0
	if err != nil {
		if exitErr, ok := err.(*exec.ExitError); ok {
			exitCode = exitErr.ExitCode()
		} else {
			return ProofSenseResult{OK: false, Signal: "exec_error", Evidence: err.Error()}
		}
	}
	return ProofSenseResult{
		OK:       exitCode == expect,
		Signal:   fmt.Sprintf("exit %d", exitCode),
		Evidence: evidence,
	}
}

func proofSenseFileSHA256(root string, check ProofCheck) ProofSenseResult {
	if len(check.Target) != 1 {
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: "file_sha256 requires one target path"}
	}
	expect, err := proofExpectedString(check.Expect)
	if err != nil {
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: err.Error()}
	}
	sum, err := sha256File(resolveProofPath(root, check.Target[0]))
	if err != nil {
		return ProofSenseResult{OK: false, Signal: "read_error", Evidence: err.Error()}
	}
	return ProofSenseResult{OK: strings.EqualFold(sum, expect), Signal: "sha256 " + sum, Evidence: "expected " + expect}
}

func proofSenseRegexInFile(root string, check ProofCheck) ProofSenseResult {
	if len(check.Target) < 1 {
		return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: "regex_in_file requires target path"}
	}
	pattern := ""
	if len(check.Target) >= 2 {
		pattern = check.Target[1]
	} else {
		value, err := proofExpectedString(check.Expect)
		if err != nil {
			return ProofSenseResult{OK: false, Signal: "invalid_check", Evidence: err.Error()}
		}
		pattern = value
	}
	re, err := regexp.Compile(pattern)
	if err != nil {
		return ProofSenseResult{OK: false, Signal: "invalid_regex", Evidence: err.Error()}
	}
	content, err := os.ReadFile(resolveProofPath(root, check.Target[0]))
	if err != nil {
		return ProofSenseResult{OK: false, Signal: "read_error", Evidence: err.Error()}
	}
	ok := re.Match(content)
	return ProofSenseResult{OK: ok, Signal: "regex " + strconv.FormatBool(ok), Evidence: pattern}
}

func proofCheckDigest(root string, check ProofCheck) (string, error) {
	canonical := struct {
		Kind        string   `json:"kind"`
		Target      []string `json:"target"`
		Expect      string   `json:"expect"`
		TimeoutMS   int      `json:"timeout_ms,omitempty"`
		Target0Hash string   `json:"target0_hash,omitempty"`
	}{
		Kind:   strings.ToLower(strings.TrimSpace(check.Kind)),
		Target: append([]string{}, check.Target...),
		Expect: proofCanonicalExpect(check.Expect),
	}
	if check.TimeoutMS > 0 {
		canonical.TimeoutMS = check.TimeoutMS
	}
	if len(check.Target) > 0 {
		if sum, ok := proofTargetHash(root, check.Target[0]); ok {
			canonical.Target0Hash = sum
		}
	}
	encoded, err := json.Marshal(canonical)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256(encoded)
	return hex.EncodeToString(sum[:]), nil
}

func proofTargetHash(root, target string) (string, bool) {
	path := resolveProofPath(root, target)
	info, err := os.Stat(path)
	if err != nil || info.IsDir() {
		return "", false
	}
	sum, err := sha256File(path)
	if err != nil {
		return "", false
	}
	return sum, true
}

func appendProofTrace(path, tool, checkDigest string, ok bool, signal, evidence string) (ProofTraceEvent, error) {
	verify, err := verifyProofTrace(path)
	if err != nil {
		return ProofTraceEvent{}, err
	}
	if !verify.OK {
		return ProofTraceEvent{}, fmt.Errorf("trace is broken at row %d; refusing to append", derefInt(verify.BrokenAt, -1))
	}
	prev := verify.HeadHash
	if prev == "" {
		prev = proofTraceGenesis
	}
	event := ProofTraceEvent{
		Version:     1,
		Time:        time.Now().UTC().Format(time.RFC3339Nano),
		Tool:        tool,
		CheckDigest: checkDigest,
		OK:          ok,
		Signal:      signal,
		Evidence:    truncateProofEvidence(evidence),
		PrevHash:    prev,
	}
	event.Hash = hashProofEvent(event)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return ProofTraceEvent{}, err
	}
	file, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return ProofTraceEvent{}, err
	}
	defer file.Close()
	row, err := json.Marshal(event)
	if err != nil {
		return ProofTraceEvent{}, err
	}
	if _, err := file.Write(append(row, '\n')); err != nil {
		return ProofTraceEvent{}, err
	}
	return event, nil
}

func verifyProofTrace(path string) (ProofTraceVerify, error) {
	file, err := os.Open(path)
	if os.IsNotExist(err) {
		return ProofTraceVerify{OK: true, Rows: 0, HeadHash: proofTraceGenesis}, nil
	}
	if err != nil {
		return ProofTraceVerify{}, err
	}
	defer file.Close()

	prev := proofTraceGenesis
	rows := 0
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		var event ProofTraceEvent
		if err := json.Unmarshal([]byte(line), &event); err != nil {
			idx := rows
			return ProofTraceVerify{OK: false, Rows: rows + 1, HeadHash: prev, BrokenAt: &idx, Reason: "invalid JSON"}, nil
		}
		expectedHash := hashProofEvent(event)
		if event.PrevHash != prev || event.Hash != expectedHash {
			idx := rows
			return ProofTraceVerify{OK: false, Rows: rows + 1, HeadHash: prev, BrokenAt: &idx, Reason: "hash chain mismatch"}, nil
		}
		prev = event.Hash
		rows++
	}
	if err := scanner.Err(); err != nil {
		return ProofTraceVerify{}, err
	}
	return ProofTraceVerify{OK: true, Rows: rows, HeadHash: prev}, nil
}

func proofAccept(root, tracePath string, check ProofCheck) (ProofGateResult, error) {
	digest, err := proofCheckDigest(root, check)
	if err != nil {
		return ProofGateResult{}, err
	}
	verify, err := verifyProofTrace(tracePath)
	if err != nil {
		return ProofGateResult{}, err
	}
	current := proofSense(root, check)
	sawRed, greenAfterRed, err := proofTraceRedGreen(tracePath, digest)
	if err != nil {
		return ProofGateResult{}, err
	}
	result := ProofGateResult{
		CheckDigest:     digest,
		TraceIntact:     verify.OK,
		SawRed:          sawRed,
		GreenAfterRed:   greenAfterRed,
		CurrentlyGreen:  current.OK,
		CurrentSignal:   current.Signal,
		CurrentEvidence: current.Evidence,
	}
	result.OK = result.TraceIntact && result.SawRed && result.GreenAfterRed && result.CurrentlyGreen
	switch {
	case result.OK:
		result.Reason = "failure-first satisfied: red->green in an intact trace, currently green"
	case !result.TraceIntact:
		result.Reason = "trace is not intact"
	case !result.SawRed:
		result.Reason = "no RED observation for this check in the trace"
	case !result.GreenAfterRed:
		result.Reason = "no GREEN observation after RED for this check"
	case !result.CurrentlyGreen:
		result.Reason = "check is not currently green"
	default:
		result.Reason = "acceptance rejected"
	}
	return result, nil
}

func proofTraceRedGreen(path, digest string) (bool, bool, error) {
	file, err := os.Open(path)
	if os.IsNotExist(err) {
		return false, false, nil
	}
	if err != nil {
		return false, false, err
	}
	defer file.Close()
	sawRed := false
	greenAfterRed := false
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		var event ProofTraceEvent
		if err := json.Unmarshal([]byte(line), &event); err != nil {
			continue
		}
		if event.Tool != "sense" || event.CheckDigest != digest {
			continue
		}
		if !event.OK {
			sawRed = true
			continue
		}
		if sawRed && event.OK {
			greenAfterRed = true
		}
	}
	if err := scanner.Err(); err != nil {
		return false, false, err
	}
	return sawRed, greenAfterRed, nil
}

func hashProofEvent(event ProofTraceEvent) string {
	event.Hash = ""
	encoded, _ := json.Marshal(event)
	sum := sha256.Sum256([]byte(event.PrevHash + string(encoded)))
	return hex.EncodeToString(sum[:])
}

func sha256File(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()
	hash := sha256.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}
	return hex.EncodeToString(hash.Sum(nil)), nil
}

func proofExpectedExit(value any) (int, error) {
	if value == nil {
		return 0, nil
	}
	switch typed := value.(type) {
	case int:
		return typed, nil
	case float64:
		if typed != float64(int(typed)) {
			return 0, fmt.Errorf("command_exit expect must be an integer exit code")
		}
		return int(typed), nil
	case string:
		parsed, err := strconv.Atoi(typed)
		if err != nil {
			return 0, fmt.Errorf("command_exit expect must be an integer exit code")
		}
		return parsed, nil
	default:
		return 0, fmt.Errorf("command_exit expect must be an integer exit code")
	}
}

func proofExpectedString(value any) (string, error) {
	switch typed := value.(type) {
	case string:
		return typed, nil
	case nil:
		return "", fmt.Errorf("expect string is required")
	default:
		return "", fmt.Errorf("expect must be a string")
	}
}

func proofCanonicalExpect(value any) string {
	switch typed := value.(type) {
	case nil:
		return ""
	case int:
		return strconv.Itoa(typed)
	case float64:
		if typed == float64(int(typed)) {
			return strconv.Itoa(int(typed))
		}
		return strconv.FormatFloat(typed, 'f', -1, 64)
	case string:
		return typed
	default:
		encoded, _ := json.Marshal(typed)
		return string(encoded)
	}
}

func resolveProofTracePath(root, path string) string {
	if strings.TrimSpace(path) == "" {
		path = defaultProofTrace
	}
	return resolveInputPath(root, path)
}

func resolveProofPath(root, path string) string {
	if filepath.IsAbs(path) {
		return path
	}
	return filepath.Join(root, filepath.FromSlash(path))
}

func truncateProofEvidence(value string) string {
	value = strings.TrimSpace(value)
	const limit = 4000
	if len(value) <= limit {
		return value
	}
	return value[:limit] + "...[truncated]"
}

func writeProofJSON(w io.Writer, value any) {
	encoder := json.NewEncoder(w)
	encoder.SetIndent("", "  ")
	_ = encoder.Encode(value)
}

func derefInt(value *int, fallback int) int {
	if value == nil {
		return fallback
	}
	return *value
}
