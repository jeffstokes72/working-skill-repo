package main

import (
	"path/filepath"
	"testing"
)

func TestReleaseChecksUseNativeCoreNotPSGate(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "go.mod"), "module fixture\n")

	checks, err := releaseChecks(root, "local-release", func(root string, check Check) CheckResult {
		return CheckResult{ExitCode: 0}
	})
	if err != nil {
		t.Fatalf("releaseChecks returned error: %v", err)
	}
	if checks[0].Name != "kb-check-all" || checks[0].CommandString() != "kbcheck core" {
		t.Fatalf("expected native core release check, got %+v", checks[0])
	}
	for _, check := range checks {
		if check.Name == "kb-release-gate" || check.CommandString() == "scripts/kb-release-gate.ps1" {
			t.Fatalf("release gate must not delegate to kb-release-gate.ps1: %+v", check)
		}
	}
}

func TestLiveReleaseUsesNativeLiveCorpus(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "go.mod"), "module fixture\n")
	writeFile(t, filepath.Join(root, "evals", "route-complexity", "fixture.json"), "{}")
	checks, err := releaseChecks(root, "live-release", func(root string, check Check) CheckResult {
		return CheckResult{ExitCode: 0}
	})
	if err != nil {
		t.Fatalf("releaseChecks returned error: %v", err)
	}
	found := false
	for _, check := range checks {
		if check.Name == "live-codex-ghcp-corpus" {
			found = true
			if check.CommandString() != "kbcheck eval-run-live-corpus --runtime codex,ghcp" || check.Run == nil {
				t.Fatalf("expected native live corpus check, got %+v", check)
			}
		}
	}
	if !found {
		t.Fatal("missing live corpus check")
	}
}

func TestReleaseSkipsSyncForGenericRepoWithoutSkillConfig(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "go.mod"), "module fixture\n")

	checks, err := releaseChecks(root, "local-release", func(root string, check Check) CheckResult {
		return CheckResult{ExitCode: 0}
	})
	if err != nil {
		t.Fatalf("releaseChecks returned error: %v", err)
	}
	for _, check := range checks {
		if check.Name == "skill-sync-report" {
			run := invokeReleaseCheck(root, check, func(root string, check Check) CheckResult {
				t.Fatalf("unavailable generic-repo check should not run")
				return CheckResult{}
			})
			if run.Status != "skipped-explicit" || run.Required {
				t.Fatalf("expected optional skipped-explicit, got %+v", run)
			}
			return
		}
	}
	t.Fatal("missing skill-sync-report release check")
}

func TestReleaseRequiresNativeSyncForSkillRepo(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, ".github", "skills", "demo", "SKILL.md"), "---\nname: demo\ndescription: demo\n---\n")
	writeFile(t, filepath.Join(root, "config", "skill-quality.json"), `{
	  "sync_targets": [
	    {"id":"source","path":".github/skills","classification":"source","required":true},
	    {"id":"required","path":".github/skills","classification":"required","required":true}
	  ]
	}`)

	checks, err := releaseChecks(root, "local-release", func(root string, check Check) CheckResult {
		return CheckResult{ExitCode: 0}
	})
	if err != nil {
		t.Fatalf("releaseChecks returned error: %v", err)
	}
	for _, check := range checks {
		if check.Name == "skill-sync-report" {
			if !check.Required || check.CommandString() != "kbcheck skill-sync-report" || check.Run == nil {
				t.Fatalf("expected required native sync check, got %+v", check)
			}
			return
		}
	}
	t.Fatal("missing skill-sync-report release check")
}
