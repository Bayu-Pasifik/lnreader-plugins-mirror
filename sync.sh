#!/usr/bin/env bash
# Salin branch plugins/v3.0.0 dari lnreader-plugins ke branch yang sama di repo ini.
# Aman: tanpa force-push, dan dilewati bila hasil tarikan tampak rusak.
set -euo pipefail

UP=https://github.com/lnreader/lnreader-plugins.git
BR=plugins/v3.0.0
OLD='raw.githubusercontent.com/lnreader/lnreader-plugins/'
NEW='raw.githubusercontent.com/Bayu-Pasifik/lnreader-plugins-mirror/'

work=$(mktemp -d)
trap 'git worktree prune; rm -rf "$work"' EXIT

git clone -q --depth 1 --single-branch -b "$BR" "$UP" "$work/up"
count() { node -e 'const fs=require("fs");const d=JSON.parse(fs.readFileSync(0,"utf8"));console.log(Array.isArray(d)?d.length:0)'; }

newcount=$(count < "$work/up/.dist/plugins.min.json")
if [ "$newcount" -le 0 ]; then echo "manifest upstream kosong: sinkron dilewati"; exit 0; fi

have=0
if git ls-remote --exit-code --heads origin "$BR" >/dev/null 2>&1; then
  git fetch -q origin "$BR"
  have=$(git show "origin/$BR:.dist/plugins.min.json" | count)
  git worktree add -q --detach "$work/wt" "origin/$BR"
else
  git worktree add -q --detach "$work/wt"
  git -C "$work/wt" checkout -q --orphan data
fi
if [ "$have" -gt 0 ] && [ $((newcount * 100)) -lt $((have * 80)) ]; then
  echo "plugin turun dari $have ke $newcount (>20%): sinkron dibatalkan" >&2
  exit 1
fi

cd "$work/wt"
git rm -rfq --ignore-unmatch . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
(cd "$work/up" && tar --exclude=.git -cf - .) | tar -xf -
cp "$OLDPWD/LICENSE" LICENSE
sed -i "s#$OLD#$NEW#g" .dist/plugins.json .dist/plugins.min.json
git add -A
if git diff --cached --quiet; then echo "tidak ada perubahan"; exit 0; fi
git -c user.name="mirror-bot" -c user.email="mirror-bot@users.noreply.github.com" \
  commit -q -m "sync: $newcount plugin dari lnreader-plugins"
git push -q origin "HEAD:refs/heads/$BR"
echo "tersinkron: $newcount plugin"
