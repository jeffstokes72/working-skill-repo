package main

import (
	"path/filepath"
	"testing"
)

func TestParityContractForSkillRepoCheckNames(t *testing.T) {
	t.Setenv("KBCHECK_POWERSHELL", "pwsh")
	root := t.TempDir()
	writeFile(t, filepath.Join(root, ".github", "skills", "kb-check", "SKILL.md"), "---\nname: kb-check\ndescription: test\n---\n")
	writeFile(t, filepath.Join(root, "config", "skill-quality.json"), "{}")
	for _, script := range []string{
		"scripts/skill-lint.ps1",
		"scripts/route-complexity-eval.ps1",
		"scripts/skill-eval.ps1",
		"scripts/skill-sync-report.ps1",
	} {
		writeFile(t, filepath.Join(root, filepath.FromSlash(script)), "exit 0")
	}

	checks, err := DiscoverChecks(root)
	if err != nil {
		t.Fatalf("DiscoverChecks returned error: %v", err)
	}
	got := checkNames(checks)
	want := []string{
		"cross-model-benchmark-validate",
		"kb-pipeline-selftest",
		"kb-release-gate-selftest",
		"kb-work-ready-set-selftest",
		"kb-work-scope-lease-selftest",
		"route-complexity-eval",
		"skill-eval",
		"skill-lint",
		"skill-marketplace-firebreak",
		"skill-marketplace-firebreak-selftest",
		"skill-surface-minimality",
		"skill-surface-minimality-selftest",
		"skill-surface-report",
		"skill-sync-report",
	}
	if len(got) < len(want) {
		t.Fatalf("checks=%v want at least %v", got, want)
	}
	for _, name := range want {
		if !contains(got, name) {
			t.Fatalf("checks=%v missing %s", got, name)
		}
	}
}
