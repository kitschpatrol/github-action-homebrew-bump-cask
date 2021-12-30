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
  uses: macauley/action-homebrew-bump-cask
  with:
    # Required, custom GitHub access token with the 'public_repo' and 'workflow' scopes
    token: ${{secrets.TOKEN}}
    # Optional, will create tap repo fork in organization
    org: ORG
    # Optional, defaults to homebrew/core
    tap: USER/REPO
    # Cask name, required
    cask: CASK
    # Optional, will be determined automatically
    tag: ${{github.ref}}
    # Optional, will be determined automatically
    revision: ${{github.sha}}
    # Optional, if don't want to check for already open PRs
    force: false # true
```

### Livecheck mode

If `livecheck` input is set to `true`, the Action will run `brew livecheck` to check if any provided casks are outdated or if tap contains any outdated casks and then will run `brew bump-cask-pr` on each of those casks with proper arguments to bump them.

Might be a good idea to run this on schedule in your tap repo, so one gets automated PRs updating outdated casks.

If there are no outdated casks, the Action will just exit.

```yaml
- name: Update Homebrew cask
  uses: macauley/action-homebrew-bump-cask
  with:
    # Required, custom GitHub access token with only the 'public_repo' scope enabled
    token: ${{secrets.TOKEN}}
    # Optional, will create tap repo fork in organization
    org: ORG
    # Bump all outdated casks in this tap
    tap: USER/REPO
    # Bump only these casks if outdated
    cask: CASK-1, CASK-2, CASK-3, ...
    # Optional, if don't want to check for already open PRs
    force: false # true
    # Need to set this input if want to use `brew livecheck`
    livecheck: true
```

If only `tap` input is provided, all casks in given tap will be checked and bumped if needed.

## Examples

- TBD
