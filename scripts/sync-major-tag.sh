#!/usr/bin/env bash
set -euo pipefail

# Points the bare major tag (e.g. v1) at the version tag bumpp just pushed
# (e.g. v1.2.3), so `uses: …@v1` references resolve to the latest release.

version=$(node -p "require('./package.json').version")

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Version $version is a prerelease, leaving the major tag alone"
	exit 0
fi

major_tag="v${version%%.*}"
version_tag="v${version}"

git tag --force "$major_tag" "${version_tag}^{commit}"
git push --force origin "$major_tag"
echo "Tag $major_tag now points at $version_tag"
