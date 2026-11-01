---
name: go-wails
description: Conventions for Go desktop apps built with Wails v3 — upgrading the frontend npm dependencies (including @wailsio/runtime), always showing the app version in the UI, and shipping app updates through the built-in Wails v3 updater (pkg/updater). Use when working on a Wails project, bumping its npm or Wails dependencies, adding version display, or building self-update.
---

# Go + Wails v3

## Upgrade the frontend dependencies (npm)

Run npm **inside the frontend folder** (usually `frontend/`). Running it at the repo
root creates a stray empty `package-lock.json` — delete it, never commit it.

```bash
cd frontend
npm outdated                      # what is behind
npm update --save                 # newest within the current ranges, rewrites package.json
npm install <pkg>@latest          # cross a range boundary for one package
npm install @wailsio/runtime@latest
```

- Never leave `"@wailsio/runtime": "latest"` in `package.json`. The lockfile keeps
  whatever was resolved first (it can sit on an old beta for months). `npm install
  @wailsio/runtime@latest` writes a real `^x.y.z` range.
- Keep `@wailsio/runtime` in step with `github.com/wailsapp/wails/v3` in `go.mod`
  and with the `wails3` CLI. If one moves, check the other two:

  ```bash
  go get github.com/wailsapp/wails/v3@latest && go mod tidy
  go install github.com/wailsapp/wails/v3/cmd/wails3@latest
  wails3 generate bindings          # bindings are generated against the Go side
  ```

- Verify before you commit, then start the app once to check it:

  ```bash
  npm run check                     # svelte-check / tsc, if the project has it
  npm run build
  wails3 dev                        # smoke test the real app
  ```

- Commit `package.json` and `package-lock.json` together, in one change.

## Always show the app version

The running version must always be visible in the UI, e.g. in the status bar or footer.
Don't hide it in an About dialog only.

- Stamp it at build time and default to `dev` for local builds:

  ```go
  // version is stamped at release time via -ldflags "-X main.version=v1.2.3".
  var version = "dev"
  ```

  ```yaml
  # Taskfile build flags
  -ldflags="-w -s -H windowsgui{{if .VERSION}} -X main.version={{.VERSION}}{{end}}"
  ```

- Pass `version` into the bound service and expose it with a method, so the frontend
  reads it through the generated bindings, not a hard-coded string.
- Show `dev` as-is in local builds. Never show an empty value: render a placeholder
  (`…`) while it loads.
- Next to the version, show whether an update is available (see below).

## App updates: use the Wails v3 updater

Use `github.com/wailsapp/wails/v3/pkg/updater` and its GitHub provider. Don't write
your own download, swap, or restart code.

```go
import (
	"github.com/wailsapp/wails/v3/pkg/updater"
	githubprovider "github.com/wailsapp/wails/v3/pkg/updater/providers/github"
)

func main() {
	// First line of main: Updater.Restart re-runs this exe as its swap helper.
	// It must run before single-instance / IPC handling, or the helper hands
	// over to the running app and the update fails ("helper did not signal readiness").
	updater.HandleHelperMode()
	// ... application.New(...)

	if version != "" && version != "dev" { // dev builds never check
		if err := initAppUpdater(wailsApp, version); err != nil {
			log.Printf("updater: %v (app update checks disabled)", err)
		}
	}
}

func initAppUpdater(app *application.App, version string) error {
	gh, err := githubprovider.New(githubprovider.Config{
		Repository:    "owner/repo",
		ChecksumAsset: "SHA256SUMS", // downloads are verified against it
	})
	if err != nil {
		return err
	}
	return app.Updater.Init(updater.Config{
		CurrentVersion: strings.TrimPrefix(version, "v"), // updater wants no leading "v"
		Providers:      []updater.Provider{gh},
		// No CheckInterval: nothing is checked or downloaded on its own.
	})
}
```

- `app.Updater.Check(ctx)` gives a silent check for an "update available" banner.
  Treat errors (offline, rate limit) as "no update", never as a GUI error.
- `app.Updater.CheckAndInstall(ctx)` opens the Wails update window and runs
  download → verify → install. Call it only from a user action (an Update button).
- Release assets must match the provider's default matcher
  (`<name>_<version>_windows_amd64.zip`, one top-level exe) plus `SHA256SUMS`. Pass a
  custom `AssetMatcher` only to skip extra assets (e.g. `*portable*`).
- Pre-releases stay out of the update feed unless you opt in.
