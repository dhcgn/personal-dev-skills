# Scaffold Prompt

Copy everything below the line into your agent, in an empty folder or a freshly cloned repo.

---

Scaffold this folder for agent-assisted development. Work through the steps in order. Collect all questions for the user (steps 1–4) in one round, then do the work. Never install anything without the user's yes.

## 1. Inspect

- List the folder and run `git remote -v`.
- No `.git`? Ask the user whether to run `git init`.
- Remote on `github.com`? Then step 6 applies.

## 2. OpenSpec

- Check with `openspec --version`.
- Missing: tell the user it is not installed and ask whether they want it. Install it following <https://openspec.dev/docs/installation>, then run `openspec init`.

## 3. APM skills

- Check with `apm --version`. Missing: point the user to <https://microsoft.github.io/apm/quickstart/> and skip this step.
- Ask which profile to install (default first):
  - `apm install dhcgn/personal-dev-skills/profiles/dev-base`
  - `apm install dhcgn/personal-dev-skills/profiles/dev-go` (includes dev-base)
  - `apm install dhcgn/personal-dev-skills/profiles/obsidian`
  - all skills: `apm install dhcgn/personal-dev-skills`
- The current list of profiles is in <https://github.com/dhcgn/personal-dev-skills/tree/main/profiles>, offer any new ones too.
- After installing, check that `.agents/skills/` contains the skills.

## 4. RTK

- Check with `rtk --version` and `rtk gain`. If `rtk gain` fails, a different tool named `rtk` (Rust Type Kit) is installed.
- Missing: tell the user and point to <https://github.com/rtk-ai/rtk> for install and hook setup. Do not install it yourself.

## 5. AGENTS.md

Create `AGENTS.md` in the root. Ask the user for the purpose of the repo if the folder does not make it obvious. Keep it short:

- what the repo is for, in two or three sentences
- layout (only what exists)
- how to build, test, and run
- conventions (language, line endings, commit style)

Create `CLAUDE.md` and `GEMINI.md` that contain only `@AGENTS.md`, so every harness reads the same file.

## 6. GitHub (only if the remote is on github.com)

- Use the `gh` CLI for GitHub tasks (issues, PRs, releases, workflow runs).
- Check `.github/workflows/`. When you change code, keep the workflows passing, and check runs with `gh run list` / `gh run view`.
- Add a short GitHub section to `AGENTS.md`: which workflows exist and what they check.
- Create or extend `README.md` with typical badges at the top. Take `<owner>/<repo>` from the remote and add only badges that resolve:
  - workflow status per workflow: `[![<name>](https://github.com/<owner>/<repo>/actions/workflows/<file>.yml/badge.svg)](https://github.com/<owner>/<repo>/actions/workflows/<file>.yml)`
  - latest release: `[![Release](https://img.shields.io/github/v/release/<owner>/<repo>)](https://github.com/<owner>/<repo>/releases)`
  - license: `[![License](https://img.shields.io/github/license/<owner>/<repo>)](LICENSE)`
  - language-specific, if it applies, e.g. Go: `[![Go Report Card](https://goreportcard.com/badge/github.com/<owner>/<repo>)](https://goreportcard.com/report/github.com/<owner>/<repo>)`

## 7. Report

End with a short summary: what was installed, what was skipped and why, which files were created.
