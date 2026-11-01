# My Personal Skill for Developement

Maybe these are useful for you too, I just begin to collect them. I will update it from time to time.

## Usage

- <https://microsoft.github.io/apm/quickstart/>
- All my skills: `apm install dhcgn/personal-dev-skills`
- A profile (a set of my and third-party skills):
  - `apm install dhcgn/personal-dev-skills/profiles/dev-base`
  - `apm install dhcgn/personal-dev-skills/profiles/dev-go` (includes dev-base)
  - `apm install dhcgn/personal-dev-skills/profiles/obsidian`
- Pin a release by appending the tag: `apm install dhcgn/personal-dev-skills/profiles/dev-go#v1.2.0`
- Install for every project on this machine (opencode): `apm install -g dhcgn/personal-dev-skills/profiles/dev-go --target opencode`

## Development

- Source: `.apm/skills/<name>/SKILL.md` and `.apm/instructions/`
- Profiles: `profiles/<name>/apm.yml`, they reference the skills by local path (`../../.apm/skills/<name>`)
- `.\compile-all.ps1` deploys root and profiles locally, deployed output (`.agents/`) is gitignored
- Release: `.\set-version-in-all-apm.ps1 -NewVersion 1.3.0`, commit, tag `v1.3.0`
