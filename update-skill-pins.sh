#!/usr/bin/env bash
# Pins every third-party skill in apm.yml and profiles/*/apm.yml to its newest stable tag,
# or to the newest default-branch commit SHA when the repo has no tags.
#
#   bash update-skill-pins.sh        rewrite the apm.yml files only
#   bash update-skill-pins.sh --pr   also open or refresh one pull request per repo (CI, needs GH_TOKEN)
set -euo pipefail
cd "$(dirname "$0")"

files=(apm.yml profiles/*/apm.yml)
# A remote dependency line: "- owner/repo[/sub/path][#ref]"
dep_re='^ *- ([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)(/[^#[:space:]]*)?(#([^[:space:]]*))?[[:space:]]*$'
# Only the dependencies.apm list, so MCP registry names (io.github.x/y) under mcp: stay untouched.
apm_deps() { awk 'FNR==1{f=0} /^ *apm:/{f=1;next} /^ *mcp:/{f=0} f' "${files[@]}"; }

for repo in $(apm_deps | sed -nE "s|$dep_re|\1|p" | sort -u); do
  url="https://github.com/$repo"
  # ponytail: only plain version tags (1.2.3, v1.2.3) count, pre-releases and other schemes are ignored
  latest=$(git ls-remote --tags --refs "$url" | sed 's|.*refs/tags/||' | grep -E '^v?[0-9]+(\.[0-9]+)*$' | sort -V | tail -1 || true)
  [ -n "$latest" ] || latest=$(git ls-remote "$url" HEAD | cut -f1)
  [ -n "$latest" ] || { echo "::error::cannot resolve $url" >&2; exit 1; }
  old=$(apm_deps | sed -nE "s|$dep_re|\1 \4|p" | awk -v r="$repo" '$1==r{print $2; exit}')
  echo "$repo: ${old:-unpinned} -> $latest"

  sed -i -E "/^ *apm:/,/^ *mcp:/ s|^( *- ${repo//./\\.}(/[^#[:space:]]*)?)(#[^[:space:]]*)?[[:space:]]*$|\1#$latest|" "${files[@]}"

  [ "${1:-}" = --pr ] || continue
  git diff --quiet && continue

  branch="skill-pins/${repo//\//-}"
  title="Bump $repo to $latest"
  body="Pins third-party skill \`$repo\` to \`$latest\`."
  [ -n "$old" ] && body+=$'\n\n'"Review the upstream changes before merging: $url/compare/$old...$latest"
  open=$(gh pr list --head "$branch" --json title --jq '.[].title')
  if [ "$open" = "$title" ]; then git checkout -q -- "${files[@]}"; continue; fi  # already proposed

  git switch -q -C "$branch"
  git commit -q -am "$title"
  git push -q -f origin "$branch"
  if [ -n "$open" ]; then
    gh pr edit "$branch" --title "$title" --body "$body"
  else
    gh pr create --head "$branch" --title "$title" --body "$body"
  fi
  git switch -q -
done
