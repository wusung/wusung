#!/usr/bin/env bash
# Fetch profile cards into assets/. A card is only replaced when the new
# response is a valid SVG without an error message, so a flaky upstream
# never overwrites the last good copy.
set -uo pipefail
U=wusung
declare -A CARDS=(
  [streak.svg]="https://streak-stats.demolab.com/?user=$U&theme=black-ice&hide_border=true&stroke=0000&background=060A0CD0"
  [stats.svg]="https://github-readme-stats.vercel.app/api?username=$U&show_icons=true&count_private=true&theme=react&hide_border=true&bg_color=0D1117"
  [top-langs.svg]="https://github-readme-stats.vercel.app/api/top-langs?username=$U&langs_count=8&count_private=true&layout=compact&theme=react&hide_border=true&bg_color=0D1117"
  [profile-details.svg]="https://github-profile-summary-cards.vercel.app/api/cards/profile-details?username=$U&theme=github_dark"
)
cd "$(dirname "$0")/../assets"
for name in "${!CARDS[@]}"; do
  ok=0
  for attempt in 1 2 3; do
    if curl -fsSL -m 60 -o "$name.tmp" "${CARDS[$name]}" \
      && grep -q '<svg' "$name.tmp" \
      && ! grep -qiE 'something went wrong|rate limit|error' "$name.tmp"; then
      mv "$name.tmp" "$name"; ok=1; break
    fi
    sleep 5
  done
  rm -f "$name.tmp"
  [ "$ok" = 1 ] && echo "updated $name" || echo "kept old $name"
done
