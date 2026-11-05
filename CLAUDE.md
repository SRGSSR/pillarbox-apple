# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Pillarbox is SRG SSR's reactive (Combine + SwiftUI) iOS/tvOS player ecosystem built on AVFoundation/AVKit. It is distributed as a Swift package (`Package.swift`, iOS/tvOS 16+, Swift 5 language mode). A demo app lives in `Demo/` (`Pillarbox-demo.xcodeproj`, scheme `Pillarbox-demo`). The Xcode version used by CI is pinned in `.xcode-version`.

## Commands

Run `make` to list all targets. Tooling (swiftlint, ffmpeg, ruby, etc.) is installed on the fly via `pkgx`.

- `make build-ios` / `make build-tvos`: build the demo app (via fastlane).
- `make test-ios` / `make test-tvos`: start test streams, run the full `Pillarbox-NoDebug` test scheme via fastlane, stop streams. Fastlane's `before_all` runs `ensure_git_status_clean` and `after_all` runs `reset_git_repo`, so **these targets require a clean working tree and discard uncommitted changes**. Use `xcodebuild` directly while iterating.
- `make check-quality`: SwiftLint (`--strict`), rubocop, shellcheck, markdownlint, yamllint. `make fix-quality` auto-fixes what it can. The pre-commit hook (`make git-hook-install`) runs `Scripts/public/check-quality.sh -c` on staged Swift files.
- `make clean-imports`, `make find-dead-code`: maintenance utilities.

### Running tests directly

Most tests play real HLS streams served from `http://localhost:8123` (Apple players cannot play local manifests). Start them first; some streams need ~20 s to become available:

```shell
make test-streams-start   # generates streams into /tmp/pillarbox and serves them with python http.server
make test-streams-stop
```

Run a single test (or test class / target) with the package scheme:

```shell
xcodebuild test -scheme Pillarbox-NoDebug -skipPackagePluginValidation \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:PlayerTests/PlaybackTests/testHLS
```

`-skipPackagePluginValidation` is needed because the `PillarboxPackageInfoPlugin` build tool plugin (which injects the version from git tags via the binary in `Artifacts/PackageInfo.artifactbundle`) must otherwise be trusted interactively. For tvOS use `-destination 'platform=tvOS Simulator,name=Apple TV'`. CI runs tests with `-testLanguage en -testRegion en_US`, no parallel testing, and up to 3 retries (tests are timing-sensitive).

## Architecture

### Package modules (dependency order)

- **PillarboxCore** (`Sources/Core`): generic Combine/concurrency utilities shared by everything.
- **PillarboxPlayer** (`Sources/Player`): the generic player. Contains no SRG SSR-specific code and can play any content.
- **PillarboxMonitoring** (`Sources/Monitoring`): QoE/QoS monitoring tracker for Player.
- **PillarboxAnalytics** (`Sources/Analytics`): SRG SSR analytics (Commanders Act + comScore) on top of Player.
- **PillarboxStandardConnector** (`Sources/StandardConnector`): loads assets from a standard metadata format (`PlayerData`).
- **PillarboxCoreBusiness** (`Sources/CoreBusiness`): plays SRG SSR content (URN-based), combining Analytics, Monitoring and StandardConnector.
- **PillarboxCircumspect** (`Sources/Circumspect`): Nimble-based helpers for testing Combine publishers (`expectEqualPublished`, `expectAtLeastEqualPublished`, etc.), used by all test targets.
- **PillarboxStreams** (`Sources/Streams`, not a product): `Stream` constants (`.onDemand`, `.live`, `.dvr`, …) pointing to the local test streams.

Each product has a `.docc` catalog; public API changes should keep DocC documentation in sync.

### Player internals

- `Player` (`Sources/Player/Player/`) is an `ObservableObject` wrapping a private `QueuePlayer` (an `AVQueuePlayer` subclass). Its functionality is split across `Player+*.swift` extensions (Seek, Queue, MediaSelection, ControlCenter, …).
- Rarely-changing state is `@Published` on `Player`; fast-changing state (time, buffering, seeking, playback state) is exposed only through the shared `propertiesPublisher` (`PlayerProperties`), observed via `.slice(at:)` or `View.onReceive(player:assign:to:)`. This split is intentional to limit SwiftUI redraws.
- The playlist is a `Deque<PlayerItem>` (`storedItems`); `queuePublisher` reconciles it with the `AVQueuePlayer` item list. Only a small buffer of `AVPlayerItem`s is materialized at a time (`QueueBuffer`).
- `PlayerItem` is built from an `AssetLoader` (associated `Input`/`Metadata` types): metadata is fetched through a publisher and turned into an `Asset` (simple URL, custom resource loader, FairPlay `PlaybackResource`). Connectors (StandardConnector, CoreBusiness) are implementations of this abstraction.
- Analytics/monitoring plug in via `PlayerItemTracker` (associated `Configuration`/`Metadata`) wrapped in `TrackerAdapter`s attached to a `PlayerItem`.
- Most behavior is implemented as Combine pipelines over KVO publishers in `Sources/Player/Publishers/`.
- SwiftUI views (`VideoView`, `SystemVideoView`, `Slider`, `ProgressTracker`, `VisibilityTracker`, settings menu DSL, Picture in Picture hosts) live in `Sources/Player/UserInterface/`.

### Tests

- XCTest + Nimble + Circumspect. Asynchronous tests use Nimble polling (`toEventually`, `toAlways`) or Circumspect publisher expectations; `@testable import` is used to reach internals.
- Several targets define a `TestCase` base class that raises Nimble's polling timeout (20 s); note that `toAlways`/`toNever` then also default to 20 s, so pass an explicit `until:`.
- `PlayerTests` has extra resources (`Resources`, `FileResources`) and helper tools under `Tests/PlayerTests/Tools`.

## Conventions

- Every Swift file starts with the SRG SSR copyright header (see any existing file).
- SwiftLint runs in strict mode with a large opt-in rule set (`.swiftlint.yml`), including mandatory trailing commas in multi-line collections and sorted imports; run `make check-quality` before committing.
- Imports: `@testable import` first, then other imports sorted alphabetically.
- PRs follow `.github/PULL_REQUEST_TEMPLATE.md` (document APIs, update docs, add unit tests, update the demo when relevant).
