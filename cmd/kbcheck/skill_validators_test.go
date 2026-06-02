package main

import (
	"path/filepath"
	"testing"
)

func TestSkillLintPassesValidSkillAndFailsBadFrontmatter(t *testing.T) {
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "config", "skill-quality.json"), `{
	  "lint": {
	    "skill_root": ".github/skills",
	    "require_argument_hint": "warning",
	    "required_frontmatter": ["name", "description"],
	    "scan_extensions": [".md"],
	    "hot_path_warning_lines": 10,
	    "hot_path_fail_lines": 20,
	    "allow_long_skills": {}
	  }
	}`)
	writeFile(t, filepath.Join(root, ".github", "skills", "good", "SKILL.md"), "---\nname: good\ndescription: ok\nargument-hint: test\n---\n# Good\n")

	result, err := computeSkillLint(root, "config/skill-quality.json")
	if err != nil {
		t.Fatalf("computeSkillLint returned error: %v", err)
	}
	if !result.OK {
		t.Fatalf("expected valid skill to pass: %#v", result.Errors)
	}

	writeFile(t, filepath.Join(root, ".github", "skills", "bad", "SKILL.md"), "---\nname: mismatch\n---\n# Bad\n")
	result, err = computeSkillLint(root, "config/skill-quality.json")
	if err != nil {
		t.Fatalf("computeSkillLint returned error: %v", err)
	}
	if result.OK || len(result.Errors) < 2 {
		t.Fatalf("expected bad frontmatter to fail, got %#v", result)
	}
}

func TestSkillSyncReportFindsRequiredDrift(t *testing.T) {
	root := t.TempDir()
	source := filepath.ToSlash(filepath.Join(root, "source"))
	required := filepath.ToSlash(filepath.Join(root, "required"))
	writeFile(t, filepath.Join(root, "config", "skill-quality.json"), `{
	  "sync_targets": [
	    {"id":"source","path":"`+source+`","classification":"source","required":true},
	    {"id":"required","path":"`+required+`","classification":"required","required":true},
	    {"id":"optional","path":"missing-optional","classification":"optional","required":false}
	  ]
	}`)
	writeFile(t, filepath.Join(root, "source", "demo", "SKILL.md"), "source\n")
	writeFile(t, filepath.Join(root, "required", "demo", "SKILL.md"), "drift\n")

	result, err := computeSkillSyncReport(root, "config/skill-quality.json")
	if err != nil {
		t.Fatalf("computeSkillSyncReport returned error: %v", err)
	}
	if result.OK || result.RequiredIssues != 1 {
		t.Fatalf("expected required drift, got %#v", result)
	}
}

func TestMarketplaceFirebreakFailsQuarantineActiveRoot(t *testing.T) {
	root := t.TempDir()
	market := filepath.ToSlash(filepath.Join(root, "market"))
	writeFile(t, filepath.Join(root, "config", "skill-marketplace.json"), `{
	  "marketplace": {
	    "local_root": "`+market+`",
	    "directories": {
	      "approved_skills": "skills",
	      "approved_catalog": "catalog/approved-skills.json",
	      "quarantine_catalog": "catalog/quarantined-skills.json",
	      "quarantine": "quarantine"
	    }
	  },
	  "project_local_paths": {"skills": ".github/skills"},
	  "quarantine_firebreak": {
	    "never_load_from_quarantine": true,
	    "additional_active_skill_roots": ["`+market+`/quarantine"]
	  }
	}`)

	result, err := computeMarketplaceFirebreak(root, "config/skill-marketplace.json")
	if err != nil {
		t.Fatalf("computeMarketplaceFirebreak returned error: %v", err)
	}
	if result.OK || result.IssueCount == 0 {
		t.Fatalf("expected quarantine active root failure, got %#v", result)
	}
}
