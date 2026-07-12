//go:build windows

package modelrouting

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestMain(m *testing.M) {
	root := filepath.Join(os.TempDir(), "modelrouting-private-acl-probe")
	lock, err := AcquirePrivateStateLock(root, "probe.lock", 100*time.Millisecond)
	if err == nil {
		_ = lock.Close()
		os.Exit(m.Run())
	}
	if errors.Is(err, ErrUnsafePath) || strings.Contains(err.Error(), "Access is denied") {
		fmt.Fprintf(os.Stderr, "skipping internal/modelrouting Windows tests: private ACL setup unavailable: %v\n", err)
		os.Exit(0)
	}
	fmt.Fprintf(os.Stderr, "private ACL probe failed unexpectedly: %v\n", err)
	os.Exit(1)
}
