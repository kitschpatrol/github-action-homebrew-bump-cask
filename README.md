# Homebrew bump cask GitHub Action

_This action was adapted from https://github.com/dawidd6/action-homebrew-bump-formula to work for casks rather than formula_

An action that wraps `brew bump-cask-pr` to ease the process of updating the cask on new project releases.

Runs on `ubuntu` and `macos`.
## Usage

One should use the [Personal Access Token](https://github.com/settings/tokens/new?scopes=public_repo,workflow) for `token` input to this Action, not the default `GITHUB_TOKEN`, because `brew bump-cask-pr` creates a fork of the cask's tap repository (if needed) and then creates a pull request.

> There are two ways to use this Action.

### Standard mode

Use if you want to simply bump the cask, when a new release happens.

Listen for new tags in workflow:

```yaml
on:
  push:
    tags:
      - '*'
```

The Action will extract all needed informations by itself, you just need to specify the following step in your workflow:

```yaml
- name: Update Homebrew cask
  uses: eugenesvk/action-homebrew-bump-cask@3.8.3
  with:
    token   	: ${{secrets.TOKEN}}	# Required, custom GitHub access token with the 'public_repo' and 'workflow' scopes
    cask    	: CASK              	# Required  Cask name
    tap     	: USER/REPO         	# Optional, defaults to homebrew/core
    org     	: ORG               	# Optional, will create tap repo fork in organization
    tag     	: ${{github.ref}}   	# Optional, will be determined automatically
    revision	: ${{github.sha}}   	# Optional, will be determined automatically
    force   	: false             	# Optional, if don't want to check for already open PRs
```

### Livecheck mode

If `livecheck` input is set to `true`, the Action will run `brew livecheck` to check if any provided casks are outdated or if tap contains any outdated casks and then will run `brew bump-cask-pr` on each of those casks with proper arguments to bump them.

Might be a good idea to run this on schedule in your tap repo, so one gets automated PRs updating outdated casks.

If there are no outdated casks, the Action will just exit.

```yaml
- name: Update Homebrew cask
  uses: eugenesvk/action-homebrew-bump-cask@3.8.3
  with:
    token    	: ${{secrets.TOKEN}}         	# Required, custom GitHub access token with only the 'public_repo' scope enabled
    cask     	: CASK-1, CASK-2, CASK-3, ...	# Bump only these casks if outdated
    tap      	: USER/REPO                  	# Bump all outdated casks in this tap
    org      	: ORG                        	# Optional, will create tap repo fork in organization
    force    	: false                      	# Optional, if don't want to check for already open PRs
    livecheck	: true                       	# Need to set this input if want to use `brew livecheck`
```

If only `tap` input is provided, all casks in given tap will be checked and bumped if needed.

## Examples
https://github.com/eugenesvk/homebrew-bump/blob/main/.github/workflows/bump_homebrew_cask.yml

## Known issues

- `livecheck` mode in Homebrew fails to get the latest version is target repo's versioning scheme changed (e.g., `0.1.0` from today will be sorted as an older version than some `20201023201011-abcdefg` )
- this workflow relies on monkey-patching the Homebrew repo utility commands that verify whether a dupe PR exists via GitHub APIs, so it might stop working if the patched code is changed
