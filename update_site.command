#!/bin/bash -e

ghu="abeyh"
ghr="ahmadbeyh.com"
sleep 5
cd "$(dirname $0)"
echo "Updating website..."
echo
while [ "$(gh api user --jq '.login')" != "${ghu}" ]; do
  gh auth switch
done
echo "Clearing deployment history..."
gh api "repos/${ghu}/${ghr}/deployments" --paginate -q '.[].id' | while read -r id; do
  gh api "repos/${ghu}/${ghr}/deployments/$id/statuses" -f state=inactive -f description="cleanup" --silent
  gh api "repos/${ghu}/${ghr}/deployments/$id" -X DELETE --silent
done
echo
echo "Uploading latest changes..."
git checkout --orphan main2
git add -A
git commit -m "commit"
git branch -D main
git branch -m main
git push --force origin main
git branch --set-upstream-to=origin/main main
echo
echo "Update complete."
sleep 5
