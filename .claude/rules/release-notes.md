# Release notes

Pillarbox release notes are published as [GitHub releases](https://github.com/SRGSSR/pillarbox-apple/releases), one per tag. Pushing a tag triggers `.github/workflows/releases.yml`, which delivers the demo to TestFlight. The notes themselves are written by hand. When asked to draft them, follow the format below and match previous releases. Read one with `curl -s https://api.github.com/repos/SRGSSR/pillarbox-apple/releases/latest`.

## Gathering changes

- List the merged PRs since the last tag with `git log $(git describe --tags --abbrev=0)..HEAD --oneline`. PR numbers appear as `(#1234)` in the squash-merge subjects.
- Read the diffs of user-facing PRs rather than relying on their titles alone. Breaking changes, in particular, must be identified from changes to `public`/`open` API in `Sources/`.
- Dependabot bumps, CI, linting, scripts, and documentation-only PRs don't get bullets. They only appear in GitHub's generated "What's Changed" list. Dependency updates that matter to integrators (Commanders Act, comScore, Swift version) are the exception: list them under Improvements or Fixes.

## Version number

Pillarbox follows semantic versioning, `MAJOR.MINOR.PATCH`, with tags that have no `v` prefix (for example `19.0.0`).

- Any breaking change to public API or behavior → major.
- New features without breaking changes → minor.
- Fixes and maintenance only → patch.

Propose a version number, but let the user decide.

## Format

```markdown
This release <one or two sentences summarizing the main theme>.

## Improvements

- Added support for AirPlay route selection in SwiftUI `Menu` via `Player.routePickerMenu(activeTintColor:)`.

## Fixes

- Fixed an audio leak that could occur with the first content being played.

## Breaking Changes

- `PlayerItem` custom initializers have been revised to use asset loaders instead of publishers.

## Demo Improvements

- Added a setting to choose how AirPlay is integrated in the custom player layout (button or menu).

## Demo Fixes

- Removed non-working streams.
```

- **Title** (the release name, separate from the body): a short Title Case theme, such as "Improved Asset Loading", "Custom AirPlay Route Selection" or "Playback Start Fix". Use "Maintenance Release" for dependency-only patches.
- **Sections**: use this order and omit empty ones. Library changes come first, then demo-only changes (`Demo/`). A patch release often has a single section.
- **Bullets**: one change per bullet, starting with a past-tense verb ("Added", "Fixed", "Improved", "Updated", "Removed", "Made", "Revisited", "Enabled"). End each with a period. Wrap API names in backticks and use their Swift spelling, for example `Player.actionAtItemEnd` or `Publisher.fail(onOutputFrom:with:)`. Write from the integrator's point of view: what they can now do or what was broken, not how it was implemented. Mention the platform when a change applies to only one (for example, "on tvOS 26").
- **Breaking Changes**: say what changed and what integrators must do to migrate (for example, "Follow the associated documentation link to obtain the value…"). List removed types and renamed or retyped APIs individually.
- Use GitHub alerts such as `> [!Note]` after the intro for important caveats.
- Don't write the "What's Changed" list or the "Full Changelog" link. GitHub generates them when the release is created.

Present the draft to the user. Never create the tag or the GitHub release yourself.
