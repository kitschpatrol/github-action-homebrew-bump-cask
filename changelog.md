# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Documentation

- Add MIT license and latest-release badges to the README.

### Maintenance

- Add Markdown automation to `fix` and `lint`, and update pnpm, formatting dependencies, workspace settings, and cleanup scripts.

## [3.8.11] - 2026-10-27

### Fixed

- Skip livecheck bumps with an open PR for the same cask version, logging the existing PR links and avoiding duplicate-branch push failures.

### Maintenance

- Update pnpm and GitHub release automation dependencies, and remove the temporary formatting-package release-age exception.

## [3.8.10] - 2026-10-08

### Documentation

- Refresh both workflow examples to pin upstream's 3.8.6 commit.

### Maintenance

- Correct Fork Tender's upstream repository identifier.
- Add scheduled and pull-request link checks for repository Markdown and the configured project homepage.
- Refresh pnpm, Prettier, and release tooling, pin workflow dependencies, and update contributor cleanup and ignore settings.

## [3.8.9] - 2026-09-05

### Fixed

- Restore compatibility with Homebrew versions that removed the global `safe_system` helper by using `SystemCommand.safe_system`.

### Maintenance

- Add scheduled Fork Tender automation for synchronizing upstream changes.
- Automate tagged GitHub releases with changelog extraction and synchronize stable major-version action tags while leaving prereleases unchanged.
- Upgrade pnpm and Prettier, add `bumpp` and `shx` contributor tools, and standardize editor settings and line endings.

## [3.8.8] - 2026-03-31

### Maintenance

- Update pnpm and Prettier, refresh package/editor metadata, and update metadata-sync CI with pinned checkout, restricted permissions, and disabled credential persistence.

## [3.8.7] - 2026-02-28

### Removed

- **Breaking:** Remove the unsupported `force` input and its Homebrew formula-command patch.

### Fixed

- Restore Homebrew 5.0 compatibility by making its output and error-reporting utilities available to the action.
- Skip `brew style --fix` in both bump modes to avoid RuboCop infinite loops on casks with custom URL methods.

### Documentation

- Clarify that `package.json` supports contributor scripts as well as project metadata.

### Maintenance

- Refresh pnpm and Prettier, fix pnpm hoisting, migrate Prettier configuration to TypeScript, and update metadata-sync actions.

## [3.8.6] - 2025-11-05

### Added

- Add `no_fork` to use the origin tap repository instead of creating a fork in either bump mode.
- Add `user_name` and `user_email` inputs for choosing the Git commit identity.

### Changed

- Enable Homebrew developer mode before updating and running the action.

### Fixed

- Avoid the GitHub `/user` endpoint when `user_name` and `user_email` are provided, enabling GitHub App tokens.
- Force-tap `homebrew/core` when `tap` is omitted and skip it when a custom tap is selected.
- Expose livecheck errors in logs by removing `--quiet`.

### Documentation

- Refresh examples for custom commit identity, `no_fork`, personal tokens, release triggers, and commit-pinned action references.

### Maintenance

- Delegate PyPI download handling to Homebrew, removing custom URL rewriting and `pipgrip` installation.
- Add a bundled Homebrew formula-command patch for runs using `force`.
- Establish Node.js 22+/pnpm contributor tooling with Prettier, editor configuration, repository metadata synchronization, and tag-update scripts.

## [3.8.5] - 2024-08-02

### Added

- Add an `org` input for creating tap repository forks in a selected GitHub organization.
- Add a `dryrun` input that forwards `--dry-run` to cask bumps in both standard and livecheck modes.
- Resolve PyPI-hosted download URLs and install `pipgrip` for standard-mode updates.

### Changed

- **Breaking:** Switch from formula updates to `brew bump-cask-pr`, rename the `formula` input to `cask`, and restrict livecheck to casks.
- **Breaking:** Use cask metadata and version-based bumps in standard mode, stopping forwarding of formula-specific Git tag and revision arguments.
- Continue processing livecheck JSON even when the livecheck command exits with a nonzero status.
- Expose Homebrew stderr, livecheck status/output, per-cask progress, and individual bump errors in action logs.

### Fixed

- Skip standard-mode bumps when the requested version already matches the cask definition.
- Preserve version-templated cask URLs by omitting explicit URL overrides except for PyPI downloads.
- Find Homebrew on Linux runners by adding its binary directory before invoking it.
- Use Homebrew's current GitHub REST API helper instead of the deprecated `open_api` method.

### Documentation

- Update guidance for cask workflows, organization forks, required token scopes, and fork-specific action and example references.
- Document livecheck's limitation when an upstream project changes its versioning scheme.

### Maintenance

- Remove inherited formula integration-test and Dependabot workflows from the cask fork.

## [3.5.1] - 2020-12-21

### Fixed

- Restore audit skipping for livecheck bumps by passing `--no-audit` again.

## [3.5.0] - 2020-12-11

### Changed

- Run Homebrew audit checks when bumping formulae in livecheck mode.

### Documentation

- Recommend macOS runners for updating core formulae because Ubuntu runs may encounter problems.

## [3.4.1] - 2020-09-01

### Added

- Allow livecheck mode to run without either `formula` or `tap` inputs.

### Changed

- Run `brew livecheck` without automatically adding the separate `homebrew/livecheck` tap.

## [3.4.0] - 2020-08-28

### Changed

- Run as a composite action using shell steps and Homebrew Ruby, removing the Node.js wrapper and its `@actions/core` and `@actions/exec` dependencies.

## [3.3.1] - 2020-08-21

### Fixed

- Explicitly load Homebrew's formula API before accessing formula metadata.

### Documentation

- Clarify that providing only `tap` in livecheck mode checks and updates the entire tap.

### Maintenance

- Run integration tests on every branch push while skipping README-only changes.

## [3.3.0] - 2020-07-25

### Changed

- Pass the parsed release version explicitly for archive-based standard bumps while retaining tag/revision arguments for Git-based formulae.
- Pass livecheck's latest version directly to Homebrew instead of independently deriving download URLs, Git tags, and revisions.

### Fixed

- Keep multiline arguments on a single line in command log annotations.

## [3.2.0] - 2020-07-24

### Added

- Add a `message` input for appending custom text to generated pull requests alongside the action attribution.

### Documentation

- Add another real-world formula update workflow example.

### Maintenance

- Test single-line and multiline custom pull request messages.

## [3.1.1] - 2020-07-07

### Fixed

- Run Homebrew update/reset before starting the Ruby script so it loads the updated Homebrew code.

### Documentation

- Clarify required standard-mode inputs, multiple-formula livecheck usage, and example workflows.

### Maintenance

- Adjust integration runner assignments and shorten waits between bump jobs.

## [3.1.0] - 2020-06-30

### Added

- Accept multiple formula names in livecheck mode, separated by commas, spaces, or newlines.

### Changed

- Use `@actions/core` to report wrapper failures through GitHub Actions error annotations.

### Fixed

- Skip livecheck results without version information instead of attempting to bump them.
- Construct fallback noreply email addresses from the authenticated user's login rather than the workflow actor or display name.
- Check livecheck and Git revision command failures before consuming their output.

### Documentation

- Restore Ubuntu runner guidance and correct tap-name examples.

### Maintenance

- Extend integration coverage for multiple formulae and Ubuntu execution, and adjust repeated bump tests and job sequencing.

## [3.0.3] - 2020-05-03

### Fixed

- Fetch commit author profile details from the token's authenticated GitHub account instead of the workflow actor.

### Maintenance

- Update the declared `@actions/exec` dependency to `^1.0.4`.
- Move integration tests to macOS runners.

## [3.0.2] - 2020-04-28

### Fixed

- Attempt all livecheck bumps after individual bump failures, then fail the action if any bump failed.
- Resolve Git-based livecheck revisions from a checkout of the target tag and strip trailing newlines from the resulting SHA.

### Documentation

- Document temporary lack of Ubuntu support because runner images do not provide Homebrew.

## [3.0.1] - 2020-04-22

### Changed

- Print caught execution errors before marking the action as failed.

### Fixed

- Resolve `main.rb` relative to the installed action directory instead of the workflow's working directory.

## [3.0.0] - 2020-04-20

### Added

- Add a separate `tap` input for selecting a custom formula tap.
- Add livecheck mode to detect outdated formulae in a selected formula or entire tap and open update pull requests automatically.

### Changed

- **Breaking:** Replace Docker execution with a Node.js 12 wrapper using `@actions/exec` and runner-installed Homebrew, enabling macOS execution.

### Fixed

- Propagate Ruby/Homebrew command failures to the GitHub Actions step's exit status.

### Documentation

- Document standard/livecheck usage, scheduled updates, separate tap selection, and macOS/Ubuntu runner support.

### Maintenance

- Expand integration coverage across standard/livecheck modes and macOS/Ubuntu runners, sequencing jobs that update the same formulae.

## [2.0.1] - 2020-04-09

### Fixed

- Honor `force: false` instead of enabling `--force` for every nonempty input.

### Maintenance

- Add a `force: false` integration case and restrict test runs to pushes on `master`.

## [2.0.0] - 2020-04-01

### Changed

- Derive archive download URLs from formula metadata and release tags, and default `tag` and `revision` to the workflow ref and SHA.
- Use the workflow actor's GitHub profile name and public email for commits, with GitHub noreply fallbacks.
- Disable Homebrew analytics and redundant automatic updates, and enable colored Homebrew output.

### Removed

- **Breaking:** Remove the `url`, `mirror`, and `sha256` inputs in favor of deriving archive URLs from formula metadata.

### Documentation

- Update examples for automatic source detection, workflow-derived tag/revision defaults, version-pinned actions, and fully qualified formula names.

### Maintenance

- Replace the Bash implementation with Homebrew-hosted Ruby and expand integration tests into an archive/Git matrix.

## [1.3.0] - 2020-03-18

### Changed

- Append a correctly linked action attribution to generated pull request messages.

## [1.2.0] - 2020-03-16

### Added

- Accept an optional `sha256` checksum for archive-based formula bumps.
- Accept an optional `mirror` download URL for archive-based formula bumps.

### Changed

- Print the arguments passed to `brew bump-formula-pr`.

### Fixed

- Reject missing formula names, incompatible source inputs, and missing `GITHUB_ACTOR` before performing Homebrew setup.

## [1.1.0] - 2020-03-06

### Added

- Introduce a Docker-based GitHub Action that opens formula bump pull requests for core or custom taps using an archive URL or a Git tag and revision.
- Support personal access token authentication, actor-based Git commit identity, and an optional `force` input for bypassing duplicate PR checks.

### Documentation

- Provide tag-triggered workflow examples for archive and Git-based formulae, including core/custom tap selection and personal access token setup.

### Maintenance

- Establish MIT licensing and integration workflows covering archive URL and Git revision bumps.

## [1.0.0] - 2021-12-29

### Added

- Introduce a GitHub Action wrapping `brew bump-cask-pr`, with cask/tap selection and tag/revision defaults from workflow context.
- Provide livecheck mode for selected casks or a whole tap, accepting comma-, space-, or newline-separated names and continuing other bumps after failures.
- Expose `message`, `org`, `force`, and `dryrun` inputs for configuring bump pull requests.
- Configure Git commit identity from the authenticated token user's profile, falling back to GitHub noreply addresses.

### Documentation

- Document standard/livecheck configuration, scheduling, macOS/Ubuntu runners, personal access token scopes, and an example cask workflow.

### Maintenance

- Package execution as composite shell steps using Homebrew Ruby and an initial Homebrew update/reset.

[Unreleased]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.11...HEAD
[1.0.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/releases/tag/v1.0.0
[1.1.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/releases/tag/v1.1.0
[1.2.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v1.1.0...v1.2.0
[1.3.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v1.2.0...v1.3.0
[2.0.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v1.3.0...v2.0.0
[2.0.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v2.0.0...v2.0.1
[3.0.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v2.0.1...v3.0.0
[3.0.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.0.0...v3.0.1
[3.0.2]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.0.1...v3.0.2
[3.0.3]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.0.2...v3.0.3
[3.1.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.0.3...v3.1.0
[3.1.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.1.0...v3.1.1
[3.2.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.1.1...v3.2.0
[3.3.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.2.0...v3.3.0
[3.3.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.3.0...v3.3.1
[3.4.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.3.1...v3.4.0
[3.4.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.4.0...v3.4.1
[3.5.0]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.4.1...v3.5.0
[3.5.1]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.5.0...v3.5.1
[3.8.5]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.5.1...v3.8.5
[3.8.6]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.5...v3.8.6
[3.8.7]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.6...v3.8.7
[3.8.8]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.7...v3.8.8
[3.8.9]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.8...v3.8.9
[3.8.10]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.9...v3.8.10
[3.8.11]: https://github.com/kitschpatrol/github-action-homebrew-bump-cask/compare/v3.8.10...v3.8.11
