---
description: Prefix go commands with rtk for token savings
applyTo: "**/*.go"
---

- Prefix **every** `go` command in a shell with `rtk` — arguments pass through unchanged: `rtk go test ./...`, `rtk go build ./...`, `rtk go vet ./...`, `rtk go mod tidy`, etc.
- Uncovered subcommands are no problem: rtk passes them through and returns the output unchanged, so prefixing is always safe.
- `rtk go test` prints failures only; `rtk go build` prints errors only. Route `golangci-lint run` through rtk as well: `rtk golangci-lint run`.
- If `rtk --version` fails, fall back to the raw `go` command.
- On failure, rtk tees the full raw output to a log file and prints the path — read that file instead of re-running the command unfiltered.

