package main

import (
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

func TestParseReleaseArgs(t *testing.T) {
	opts, err := parse([]string{"local-release", "--root", "repo", "--json", "--dry-run"})
	if err != nil {
		t.Fatalf("parse returned error: %v", err)
	}
	if opts.command != "local-release" || opts.root != "repo" || !opts.json || !opts.dryRun {
		t.Fatalf("unexpected options: %+v", opts)
	}
}

func TestParseRejectsJSONForCore(t *testing.T) {
	_, err := parse([]string{"core", "--json"})
	if err == nil {
		t.Fatal("expected --json to be rejected for core")
	}
}

func TestBuildLocalReleaseInvocation(t *testing.T) {
	t.Setenv("KBCHECK_POWERSHELL", "pwsh")
	root := t.TempDir()
	writeFile(t, filepath.Join(root, "scripts", "kb-release-gate.ps1"))

	inv, err := buildInvocation(options{command: "local-release", root: root, json: true})
	if err != nil {
		t.Fatalf("buildInvocation returned error: %v", err)
	}

	wantArgs := []string{
		"-NoProfile",
		"-File",
		filepath.Join(root, "scripts", "kb-release-gate.ps1"),
		"-Profile", "local-release",
		"-Root", root,
		"-Json",
	}
	if inv.exe != "pwsh" || inv.dir != root || !reflect.DeepEqual(inv.args, wantArgs) {
		t.Fatalf("unexpected invocation:\nexe=%q\ndir=%q\nargs=%v", inv.exe, inv.dir, inv.args)
	}
}

func TestBuildCoreInvocation(t *testing.T) {
	t.Setenv("KBCHECK_POWERSHELL", "powershell.exe")
	root := t.TempDir()
	writeFile(t, filepath.Join(root, ".github", "skills", "kb-check", "scripts", "kb-check.ps1"))

	inv, err := buildInvocation(options{command: "core", root: root})
	if err != nil {
		t.Fatalf("buildInvocation returned error: %v", err)
	}

	wantArgs := []string{
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File",
		filepath.Join(root, ".github", "skills", "kb-check", "scripts", "kb-check.ps1"),
		"-All",
	}
	if inv.exe != "powershell.exe" || !reflect.DeepEqual(inv.args, wantArgs) {
		t.Fatalf("unexpected invocation:\nexe=%q\nargs=%v", inv.exe, inv.args)
	}
}

func TestDryRunPrintsDelegatedCommand(t *testing.T) {
	t.Setenv("KBCHECK_POWERSHELL", "pwsh")
	root := t.TempDir()
	writeFile(t, filepath.Join(root, ".github", "skills", "kb-check", "scripts", "kb-check.ps1"))

	var out strings.Builder
	code := run([]string{"core", "--root", root, "--dry-run"}, &out, os.Stderr)
	if code != 0 {
		t.Fatalf("expected dry run to pass, got %d", code)
	}
	if !strings.Contains(out.String(), "kb-check.ps1") || !strings.Contains(out.String(), "-All") {
		t.Fatalf("dry run did not print delegated core check: %q", out.String())
	}
}

func TestBuildInvocationRejectsMissingScript(t *testing.T) {
	t.Setenv("KBCHECK_POWERSHELL", "pwsh")
	_, err := buildInvocation(options{command: "core", root: t.TempDir()})
	if err == nil || !strings.Contains(err.Error(), "required script not found") {
		t.Fatalf("expected missing script error, got %v", err)
	}
}

func writeFile(t *testing.T, path string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatalf("mkdir: %v", err)
	}
	if err := os.WriteFile(path, []byte(""), 0o644); err != nil {
		t.Fatalf("write file: %v", err)
	}
}
