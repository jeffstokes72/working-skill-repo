package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

type atvDeltaConfig struct {
	KBOwned             []string `json:"kb_owned"`
	SharedOverlap       []string `json:"shared_overlap"`
	SupersededWorkflows []string `json:"superseded_workflows"`
	ATVNative           []string `json:"atv_native"`
	SecuritySensitive   []string `json:"security_sensitive"`
}

type atvDeltaRow struct {
	Skill          string   `json:"skill"`
	Classification string   `json:"classification"`
	Paths          []string `json:"paths"`
	Statuses       []string `json:"statuses"`
	Warnings       []string `json:"warnings"`
}

type atvDeltaResult struct {
	OK          bool          `json:"ok"`
	Status      string        `json:"status"`
	Reason      string        `json:"reason,omitempty"`
	GeneratedAt string        `json:"generated_at,omitempty"`
	ATVRepo     string        `json:"atv_repo,omitempty"`
	BaseRef     string        `json:"base_ref,omitempty"`
	UpstreamRef string        `json:"upstream_ref,omitempty"`
	NoApply     bool          `json:"no_apply"`
	Rows        []atvDeltaRow `json:"rows"`
}

type gitDeltaPath struct {
	Status string
	Path   string
	Skill  string
}

func runAtvDeltaCommand(root string, opts options, stdout, stderr io.Writer) int {
	configPath := opts.config
	if configPath == "" {
		configPath = "config/atv-upstream-delta.json"
	}
	result, err := computeAtvDelta(root, opts.atvRepo, opts.baseRef, opts.upstreamRef, configPath)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if opts.json {
		writeJSON(stdout, result)
	} else {
		if result.Status != "reported" {
			fmt.Fprintln(stdout, result.Reason)
			return 0
		}
		fmt.Fprintf(stdout, "ATV upstream delta: status=%s rows=%d no_apply=true\n", result.Status, len(result.Rows))
		counts := map[string]int{}
		for _, row := range result.Rows {
			counts[row.Classification]++
		}
		for _, key := range sortedMapKeys(counts) {
			fmt.Fprintf(stdout, "%s: %d\n", key, counts[key])
		}
		for _, row := range result.Rows {
			fmt.Fprintf(stdout, "%s %s: %s\n", row.Classification, row.Skill, strings.Join(row.Paths, ", "))
			for _, warning := range row.Warnings {
				fmt.Fprintf(stdout, "WARN [%s] %s\n", row.Skill, warning)
			}
		}
	}
	return 0
}

func computeAtvDelta(root, atvRepo, baseRef, upstreamRef, configPath string) (atvDeltaResult, error) {
	var config atvDeltaConfig
	if err := readJSONFile(resolveRepoPath(root, configPath), &config); err != nil {
		return atvDeltaResult{}, fmt.Errorf("config not found: %s", configPath)
	}
	if _, err := os.Stat(atvRepo); err != nil {
		return skippedAtvDelta("ATV repo not found: " + atvRepo), nil
	}
	atvFull, _ := filepath.Abs(atvRepo)
	if !gitRefExists(atvFull, baseRef) {
		return skippedAtvDelta("Base ref not found: " + baseRef), nil
	}
	if !gitRefExists(atvFull, upstreamRef) {
		return skippedAtvDelta("Upstream ref not found: " + upstreamRef), nil
	}
	paths := []string{".github/skills", "pkg/scaffold/templates/skills", "plugins/atv-everything/skills"}
	args := append([]string{"-C", atvFull, "diff", "--name-status", "--find-renames", baseRef + ".." + upstreamRef, "--"}, paths...)
	out, err := exec.Command("git", args...).Output()
	if err != nil {
		return atvDeltaResult{}, fmt.Errorf("git diff failed: %w", err)
	}
	pathRows := []gitDeltaPath{}
	for _, line := range strings.Split(string(out), "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, "\t")
		status := parts[0]
		path := parts[len(parts)-1]
		skill := skillNameFromAtvPath(path)
		if skill == "" {
			continue
		}
		pathRows = append(pathRows, gitDeltaPath{Status: status, Path: path, Skill: skill})
	}
	grouped := map[string][]gitDeltaPath{}
	for _, row := range pathRows {
		grouped[row.Skill] = append(grouped[row.Skill], row)
	}
	skills := make([]string, 0, len(grouped))
	for skill := range grouped {
		skills = append(skills, skill)
	}
	sort.Strings(skills)
	rows := []atvDeltaRow{}
	for _, skill := range skills {
		group := grouped[skill]
		paths := uniqueSortedDelta(group, func(row gitDeltaPath) string { return row.Path })
		statuses := uniqueSortedDelta(group, func(row gitDeltaPath) string { return row.Status })
		rows = append(rows, atvDeltaRow{
			Skill: skill, Classification: atvDeltaClass(skill, config), Paths: paths, Statuses: statuses,
			Warnings: atvSecurityWarnings(atvFull, baseRef, upstreamRef, skill, paths, config),
		})
	}
	return atvDeltaResult{
		OK: true, Status: "reported", GeneratedAt: time.Now().Format(time.RFC3339Nano),
		ATVRepo: atvFull, BaseRef: baseRef, UpstreamRef: upstreamRef, NoApply: true, Rows: rows,
	}, nil
}

func skippedAtvDelta(reason string) atvDeltaResult {
	return atvDeltaResult{OK: true, Status: "skipped-explicit", Reason: reason, NoApply: true, Rows: []atvDeltaRow{}}
}

func gitRefExists(repo, ref string) bool {
	cmd := exec.Command("git", "-C", repo, "rev-parse", "--verify", ref+"^{commit}")
	return cmd.Run() == nil
}

func skillNameFromAtvPath(path string) string {
	normalized := filepath.ToSlash(path)
	patterns := []*regexp.Regexp{
		regexp.MustCompile(`^\.github/skills/([^/]+)/`),
		regexp.MustCompile(`^pkg/scaffold/templates/skills/([^/]+)/`),
		regexp.MustCompile(`^plugins/atv-everything/skills/([^/]+)/`),
	}
	for _, pattern := range patterns {
		match := pattern.FindStringSubmatch(normalized)
		if len(match) > 1 {
			return match[1]
		}
	}
	return ""
}

func atvDeltaClass(skill string, config atvDeltaConfig) string {
	if globMatchAny(skill, config.KBOwned) {
		return "kb-owned-reject"
	}
	if globMatchAny(skill, config.SharedOverlap) {
		return "shared-overlap-review"
	}
	if globMatchAny(skill, config.SupersededWorkflows) {
		return "superseded-workflow-reject"
	}
	if globMatchAny(skill, config.ATVNative) {
		return "atv-native-candidate"
	}
	return "unknown-review"
}

func globMatchAny(value string, patterns []string) bool {
	for _, pattern := range patterns {
		regex := "^" + strings.ReplaceAll(regexp.QuoteMeta(pattern), `\*`, ".*") + "$"
		if regexp.MustCompile(regex).MatchString(value) {
			return true
		}
	}
	return false
}

func atvSecurityWarnings(repo, baseRef, upstreamRef, skill string, paths []string, config atvDeltaConfig) []string {
	if !globMatchAny(skill, config.SecuritySensitive) {
		return []string{}
	}
	warnings := []string{"security-sensitive skill; compare OSV/security proof before accepting upstream changes"}
	args := append([]string{"-C", repo, "diff", "--unified=0", baseRef + ".." + upstreamRef, "--"}, paths...)
	out, err := exec.Command("git", args...).Output()
	if err == nil && regexp.MustCompile(`(?im)^-.*osv`).Match(out) {
		warnings = append(warnings, "possible OSV proof removal detected in upstream delta")
	}
	return warnings
}

func uniqueSortedDelta(rows []gitDeltaPath, pick func(gitDeltaPath) string) []string {
	seen := map[string]bool{}
	out := []string{}
	for _, row := range rows {
		value := pick(row)
		if !seen[value] {
			seen[value] = true
			out = append(out, value)
		}
	}
	sort.Strings(out)
	return out
}

func runAtvDeltaSelftest(stdout, stderr io.Writer) int {
	root, err := os.MkdirTemp("", "atv-delta-*")
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	configPath := filepath.Join(root, "atv-upstream-delta.json")
	defer os.RemoveAll(root)
	if err := gitInitForSelftest(root); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	fixtures := map[string]string{
		".github/skills/atv-security/SKILL.md": "uses osv-scanner",
		".github/skills/kb-start/SKILL.md":     "kb",
		".github/skills/ce-review/SKILL.md":    "ce",
		".github/skills/lfg/SKILL.md":          "lfg",
		".github/skills/native-skill/SKILL.md": "native",
		".github/skills/mystery/SKILL.md":      "mystery",
	}
	for path, text := range fixtures {
		if err := writeSelftestText(filepath.Join(root, filepath.FromSlash(path)), text); err != nil {
			fmt.Fprintln(stderr, err)
			return 1
		}
	}
	if err := gitRun(root, "add", "."); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if err := gitRun(root, "commit", "-m", "base"); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if err := gitRun(root, "branch", "base"); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if err := gitRun(root, "checkout", "-b", "upstream"); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	for path := range fixtures {
		text := strings.TrimSuffix(filepath.Base(filepath.Dir(path)), "-skill") + " upstream"
		if path == ".github/skills/atv-security/SKILL.md" {
			text = "security without scanner"
		}
		if err := writeSelftestText(filepath.Join(root, filepath.FromSlash(path)), text); err != nil {
			fmt.Fprintln(stderr, err)
			return 1
		}
	}
	if err := gitRun(root, "add", "."); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	if err := gitRun(root, "commit", "-m", "upstream"); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	config := map[string]any{
		"schema_version":       1,
		"kb_owned":             []string{"kb-*"},
		"shared_overlap":       []string{"ce-review"},
		"superseded_workflows": []string{"lfg"},
		"atv_native":           []string{"atv-security", "native-*"},
		"security_sensitive":   []string{"atv-security"},
	}
	content, _ := json.MarshalIndent(config, "", "  ")
	if err := os.WriteFile(configPath, content, 0o644); err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	before, _ := exec.Command("git", "-C", root, "status", "--short").Output()
	report, err := computeAtvDelta(root, root, "base", "upstream", configPath)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}
	after, _ := exec.Command("git", "-C", root, "status", "--short").Output()
	if string(before) != string(after) {
		fmt.Fprintln(stderr, "delta report mutated git status")
		return 1
	}
	expected := map[string]string{
		"kb-start": "kb-owned-reject", "ce-review": "shared-overlap-review",
		"lfg": "superseded-workflow-reject", "native-skill": "atv-native-candidate",
		"mystery": "unknown-review",
	}
	classes := map[string]string{}
	warnings := map[string]int{}
	for _, row := range report.Rows {
		classes[row.Skill] = row.Classification
		warnings[row.Skill] = len(row.Warnings)
	}
	for skill, class := range expected {
		if classes[skill] != class {
			fmt.Fprintf(stderr, "expected %s to be %s, got %s\n", skill, class, classes[skill])
			return 1
		}
	}
	if warnings["atv-security"] < 1 {
		fmt.Fprintln(stderr, "expected atv-security security warning")
		return 1
	}
	fmt.Fprintln(stdout, "atv-upstream-delta selftest passed")
	return 0
}

func gitInitForSelftest(root string) error {
	if err := gitRun(root, "init"); err != nil {
		return err
	}
	if err := gitRun(root, "config", "user.email", "test@example.com"); err != nil {
		return err
	}
	return gitRun(root, "config", "user.name", "ATV Delta Test")
}

func gitRun(root string, args ...string) error {
	cmd := exec.Command("git", append([]string{"-C", root}, args...)...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("git %s failed: %w\n%s", strings.Join(args, " "), err, string(out))
	}
	return nil
}

func writeSelftestText(path, text string) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, []byte(text), 0o644)
}
