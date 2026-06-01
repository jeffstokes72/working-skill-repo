package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

const usage = `kbcheck is a thin cross-platform entrypoint for the existing KB PowerShell gates.

Usage:
  kbcheck core [--root <path>] [--dry-run]
  kbcheck local-release [--root <path>] [--json] [--dry-run]
  kbcheck live-release [--root <path>] [--json] [--dry-run]
  kbcheck help

Commands:
  core           Run .github/skills/kb-check/scripts/kb-check.ps1 -All.
  local-release  Run scripts/kb-release-gate.ps1 -Profile local-release.
  live-release   Run scripts/kb-release-gate.ps1 -Profile live-release.

Notes:
  This wrapper still delegates to PowerShell scripts. It does not port the
  harness away from PowerShell; install PowerShell 7 (pwsh) for macOS/Linux.
`

type invocation struct {
	exe  string
	args []string
	dir  string
}

type options struct {
	command string
	root    string
	json    bool
	dryRun  bool
}

func main() {
	code := run(os.Args[1:], os.Stdout, os.Stderr)
	os.Exit(code)
}

func run(args []string, stdout, stderr io.Writer) int {
	opts, err := parse(args)
	if err != nil {
		fmt.Fprintln(stderr, err)
		fmt.Fprintln(stderr)
		fmt.Fprint(stderr, usage)
		return 2
	}

	if opts.command == "help" {
		fmt.Fprint(stdout, usage)
		return 0
	}

	inv, err := buildInvocation(opts)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}

	if opts.dryRun {
		fmt.Fprintf(stdout, "%s %s\n", inv.exe, quoteArgs(inv.args))
		return 0
	}

	cmd := exec.Command(inv.exe, inv.args...)
	cmd.Dir = inv.dir
	cmd.Stdout = stdout
	cmd.Stderr = stderr
	cmd.Stdin = os.Stdin
	if err := cmd.Run(); err != nil {
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			return exitErr.ExitCode()
		}
		fmt.Fprintln(stderr, err)
		return 1
	}
	return 0
}

func parse(args []string) (options, error) {
	if len(args) == 0 {
		return options{command: "help", root: "."}, nil
	}

	cmd := args[0]
	if cmd == "-h" || cmd == "--help" || cmd == "help" {
		return options{command: "help", root: "."}, nil
	}

	if cmd != "core" && cmd != "local-release" && cmd != "live-release" {
		return options{}, fmt.Errorf("unknown command %q", cmd)
	}

	fs := flag.NewFlagSet(cmd, flag.ContinueOnError)
	fs.SetOutput(io.Discard)
	opts := options{command: cmd, root: "."}
	fs.StringVar(&opts.root, "root", ".", "repository root")
	fs.BoolVar(&opts.json, "json", false, "emit JSON when supported")
	fs.BoolVar(&opts.dryRun, "dry-run", false, "print the delegated command instead of running it")
	if err := fs.Parse(args[1:]); err != nil {
		return options{}, err
	}
	if fs.NArg() > 0 {
		return options{}, fmt.Errorf("unexpected argument %q", fs.Arg(0))
	}
	if opts.command == "core" && opts.json {
		return options{}, fmt.Errorf("--json is only supported for release gate commands")
	}
	return opts, nil
}

func buildInvocation(opts options) (invocation, error) {
	root, err := filepath.Abs(opts.root)
	if err != nil {
		return invocation{}, fmt.Errorf("resolve root: %w", err)
	}

	ps, err := findPowerShell()
	if err != nil {
		return invocation{}, err
	}

	args := powerShellBaseArgs(ps)
	switch opts.command {
	case "core":
		script := filepath.Join(root, ".github", "skills", "kb-check", "scripts", "kb-check.ps1")
		if err := requireFile(script); err != nil {
			return invocation{}, err
		}
		args = append(args,
			"-File",
			script,
			"-All",
		)
	case "local-release", "live-release":
		profile := opts.command
		script := filepath.Join(root, "scripts", "kb-release-gate.ps1")
		if err := requireFile(script); err != nil {
			return invocation{}, err
		}
		args = append(args,
			"-File",
			script,
			"-Profile", profile,
			"-Root", root,
		)
		if opts.json {
			args = append(args, "-Json")
		}
	default:
		return invocation{}, fmt.Errorf("unsupported command %q", opts.command)
	}

	return invocation{exe: ps, args: args, dir: root}, nil
}

func requireFile(path string) error {
	info, err := os.Stat(path)
	if err != nil {
		return fmt.Errorf("required script not found: %s", path)
	}
	if info.IsDir() {
		return fmt.Errorf("required script is a directory: %s", path)
	}
	return nil
}

func findPowerShell() (string, error) {
	if override := os.Getenv("KBCHECK_POWERSHELL"); override != "" {
		return override, nil
	}
	for _, candidate := range []string{"pwsh", "powershell"} {
		if path, err := exec.LookPath(candidate); err == nil {
			return path, nil
		}
	}
	if runtime.GOOS == "windows" {
		if path, err := exec.LookPath("powershell.exe"); err == nil {
			return path, nil
		}
	}
	return "", errors.New("PowerShell not found; install PowerShell 7 (pwsh) or set KBCHECK_POWERSHELL")
}

func powerShellBaseArgs(exe string) []string {
	base := strings.ToLower(filepath.Base(exe))
	if base == "powershell" || base == "powershell.exe" {
		return []string{"-NoProfile", "-ExecutionPolicy", "Bypass"}
	}
	return []string{"-NoProfile"}
}

func quoteArgs(args []string) string {
	quoted := make([]string, 0, len(args))
	for _, arg := range args {
		if arg == "" || strings.ContainsAny(arg, " \t\"") {
			quoted = append(quoted, `"`+strings.ReplaceAll(arg, `"`, `\"`)+`"`)
			continue
		}
		quoted = append(quoted, arg)
	}
	return strings.Join(quoted, " ")
}
