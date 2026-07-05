package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"strings"
)

type learningAdoptionInput struct {
	CandidateInstruction string                 `json:"candidate_instruction,omitempty"`
	HoldoutStrings       []string               `json:"holdout_strings,omitempty"`
	Cases                []learningAdoptionCase `json:"cases"`
}

type learningAdoptionCase struct {
	ID               string `json:"id"`
	BaselineCorrect  bool   `json:"baseline_correct"`
	CandidateCorrect bool   `json:"candidate_correct"`
}

type learningAdoptionResult struct {
	OK            bool     `json:"ok"`
	Status        string   `json:"status"`
	SampleCount   int      `json:"sample_count"`
	BaselinePass  int      `json:"baseline_pass"`
	CandidatePass int      `json:"candidate_pass"`
	NetGain       int      `json:"net_gain"`
	GainPP        float64  `json:"gain_pp"`
	RightToWrong  int      `json:"right_to_wrong"`
	WrongToRight  int      `json:"wrong_to_right"`
	Issues        []string `json:"issues"`
}

func runLearningAdoptionCommand(root string, opts options, stdout, stderr io.Writer) int {
	if opts.resultPath == "" {
		fmt.Fprintln(stderr, "learning-adoption requires --result-path")
		return 2
	}
	content, err := os.ReadFile(resolveInputPath(root, opts.resultPath))
	if err != nil {
		fmt.Fprintf(stderr, "read result path: %v\n", err)
		return 1
	}
	var input learningAdoptionInput
	if err := json.Unmarshal(content, &input); err != nil {
		fmt.Fprintf(stderr, "parse adoption input: %v\n", err)
		return 1
	}
	result := evaluateLearningAdoption(input)
	writeProofJSON(stdout, result)
	if !result.OK {
		return 1
	}
	return 0
}

func evaluateLearningAdoption(input learningAdoptionInput) learningAdoptionResult {
	result := learningAdoptionResult{SampleCount: len(input.Cases)}
	for _, c := range input.Cases {
		if c.BaselineCorrect {
			result.BaselinePass++
		}
		if c.CandidateCorrect {
			result.CandidatePass++
		}
		switch {
		case c.BaselineCorrect && !c.CandidateCorrect:
			result.RightToWrong++
		case !c.BaselineCorrect && c.CandidateCorrect:
			result.WrongToRight++
		}
	}
	result.NetGain = result.CandidatePass - result.BaselinePass
	if result.SampleCount > 0 {
		result.GainPP = (float64(result.NetGain) / float64(result.SampleCount)) * 100
	}
	if result.SampleCount < 20 {
		result.Issues = append(result.Issues, "insufficient_sample_count")
	}
	if result.NetGain < 2 && result.GainPP < 10 {
		result.Issues = append(result.Issues, "insufficient_gain")
	}
	if result.RightToWrong > 0 {
		result.Issues = append(result.Issues, "right_to_wrong_regression")
	}
	if hasHoldoutLeakage(input.CandidateInstruction, input.HoldoutStrings) {
		result.Issues = append(result.Issues, "holdout_leakage")
	}
	result.OK = len(result.Issues) == 0
	if result.OK {
		result.Status = "ADOPT_ELIGIBLE"
	} else {
		result.Status = "REJECT"
	}
	return result
}

func hasHoldoutLeakage(instruction string, holdout []string) bool {
	normalizedInstruction := strings.ToLower(instruction)
	for _, item := range holdout {
		item = strings.TrimSpace(strings.ToLower(item))
		if item == "" {
			continue
		}
		if strings.Contains(normalizedInstruction, item) {
			return true
		}
	}
	return false
}

func containsString(values []string, target string) bool {
	for _, value := range values {
		if value == target {
			return true
		}
	}
	return false
}
