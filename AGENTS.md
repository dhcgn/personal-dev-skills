# Working in personal-dev-skills

An [APM](https://microsoft.github.io/apm/) package of my agent skills, plus profiles that bundle sets of skills.
It works with any agent harness: skills deploy to `.agents/skills/`, and rules are compiled into this file. Tested with APM 0.35.0.

## Layout

```
apm.yml                               root package: ships everything in .apm/, targets: opencode, no external deps
.apm/skills/<name>/SKILL.md           skills (source of truth)
.apm/instructions/*.instructions.md   always-on rules, compiled into this file
profiles/<name>/apm.yml               profile = a set of skills; only apm.yml is committed
compile-all.ps1                       deploy root + every profile locally
set-version-in-all-apm.ps1            set the version in root + every profile
```

These files are generated and gitignored, so never edit them: `.agents/`, `apm_modules/`, `profiles/*/apm.lock.yaml`.
In this file, only the block between the `apm:start` and `apm:end` markers at the bottom is generated (`compilation.agents_md.mode: managed_section`). Never write the full marker comments anywhere else in this file: APM requires each marker exactly once and fails otherwise.

## Add a skill

1. Create `.apm/skills/<name>/SKILL.md`:
   ```markdown
   ---
   name: <name>
   description: <what it does>. Use when <trigger>.
   ---
   ```
   `name` must equal the folder name. The description decides when an agent loads the skill, so state both what it does and when to use it. Put extra files next to it (`scripts/`, `references/`, `assets/`) and link them relative from SKILL.md.
2. The root package picks it up automatically (`includes: auto`).
3. Add it to every profile that should have it: `- path: ../../.apm/skills/<name>`.
4. Run `.\compile-all.ps1` and check `profiles/<profile>/.agents/skills/<name>/`.

## Add a third-party skill

Add it to a profile's `dependencies.apm`:

- `owner/repo` installs the whole package.
- `owner/repo/path/to/skill` installs one skill folder. Use this when the repo is a Claude plugin marketplace (like `spf13/go-skills`), because the repo root then deploys nothing.
- Append `#tag` or `#sha` to pin it.

After installing, check that every expected skill is in `profiles/<profile>/.agents/skills/`. A missing folder means the reference deploys nothing.

## Add an instruction

Use an instruction only for rules that must always apply. Prefer a skill: it loads on demand and costs no context otherwise.

`.apm/instructions/<name>.instructions.md`:

```markdown
---
description: <short summary>
applyTo: "**/*.go"
---

- <rule>
```

`apm compile` (run by compile-all.ps1) writes it into the generated section below. Instructions ship with the root package only, because profiles use the `agent-skills` target, which has no instructions.

## Add an MCP server

Add it to `dependencies.mcp` in the root `apm.yml` or in a profile:

```yaml
dependencies:
  mcp:
    - io.github.github/github-mcp-server        # from the MCP registry
    - name: my-server                           # self-defined
      registry: false
      transport: stdio                          # or http + url:
      command: npx
      args: ["-y", "my-mcp-server"]
      env:
        API_KEY: ${env:MY_API_KEY}              # reference secrets, never write them here
```

- `agent-skills` has no MCP support. `apm install` fails when a profile declares MCP with only that target, so use `targets: [agent-skills, opencode]` there.
- With `opencode`, install writes the server into `opencode.json` in that folder. In a profile that file is output, so add `profiles/*/opencode.json` to `.gitignore`.
- Consumers get self-defined servers from a package only with `apm install --trust-transitive-mcp`, or by declaring them again.

## Profiles

- **New profile:** copy `profiles/dev-base/apm.yml` to `profiles/<name>/apm.yml`, then change `name`, `description` and the dependencies. Keep `version` equal to the root.
- **Compose profiles:** `- path: ../dev-base` includes another profile.
- **Own skills:** always reference them by path (`../../.apm/skills/<name>`), never as `dhcgn/personal-dev-skills/...`. A path deploys local edits without a push, and consumers get it from the same commit as the profile.
- **README:** add the install line for the new profile to README.md.
- compile-all.ps1 picks up every folder in `profiles/` automatically.

## Test

- **Local:** run `.\compile-all.ps1`, then check `.agents/skills/` (root) and `profiles/<name>/.agents/skills/`.
- **Remote (before merging):** push a branch, then in an empty folder run:
  ```bash
  apm install dhcgn/personal-dev-skills/profiles/<name>#<branch>
  ```
  The `apm.lock.yaml` there must list `dhcgn/personal-dev-skills` at the branch commit, with no local paths.

## Release

1. Run `.\set-version-in-all-apm.ps1 -NewVersion X.Y.Z`. Bump the major version when an existing install command now gives a different result, for example when a skill or profile is removed.
2. Update the `#vX.Y.Z` pin example in README.md.
3. Commit as `Release vX.Y.Z`, run `git tag -a vX.Y.Z -m "Release vX.Y.Z - <summary>"`, then push main and the tag.
4. Run `gh release create vX.Y.Z --verify-tag --title vX.Y.Z --notes-file <notes.md>`. Notes: breaking changes, new, changed, install command.

## Conventions

- LF line endings (`.gitattributes`, `.editorconfig`).
- `CLAUDE.md` and `GEMINI.md` only contain `@AGENTS.md`, so every harness reads this file.

<!-- apm:start -->
# AGENTS.md
<!-- Generated by APM CLI from distributed .apm/ primitives -->
<!-- Build ID: d9a051a8316c -->

## Files matching `**/*.ps1`

- Use Write-Progress for long-running operations to provide feedback to the user.
- Add a Powershell comment-based help block at the top of each script to provide usage information.
- Check Non-native commands before executing them to ensure they are available on the system.
- If script requires elevated privileges, check for administrative rights at the beginning of the script and provide a clear message if not running as an administrator.
- Try to ensure idempotence to avoid unintended side effects when running scripts multiple times.
- A cancelation mechanism should be implemented for long-running scripts, allowing users to stop the script gracefully and clean up any resources or temporary files.
<!-- apm:end -->
