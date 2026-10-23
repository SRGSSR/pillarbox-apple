---
paths:
  - "Sources/**/*.swift"
---

# API design

Pillarbox is a public library used by SRG SSR apps and third parties. Every `public` symbol is a commitment, and changing it means a major release (see `release-notes.md`). Keep the public surface small, and ask before adding public API that the task doesn't strictly require.

## General principles

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/). Name APIs after AVFoundation and SwiftUI equivalents when they exist (`actionAtItemEnd`, `allowsExternalPlayback`, `isMuted`) so that Apple developers feel at home.
- PillarboxPlayer must stay generic and must never contain SRG SSR-specific code. SRG SSR concerns belong in PillarboxCoreBusiness and PillarboxAnalytics. Code that is generic but not player-related belongs in PillarboxCore.
- Player APIs are main-thread only. They aren't annotated with `@MainActor`, but they're documented as such. Callbacks that run on another queue must say so in their documentation (`> Important: This method is called on a background serial queue.`).
- Every public symbol is documented (`missing_docs` is enforced). Use the `swift-docs` skill.

## Shapes that recur in the codebase

- **Reactive state.** `Player` is an `ObservableObject`. Properties that rarely change are `@Published` or are computed and trigger `objectWillChange`. Properties that change often (time, buffering, seeking) are exposed only through `propertiesPublisher`, which clients narrow with `.slice(at:)`, to avoid unnecessary SwiftUI body refreshes. Decide which category a new property belongs to, and never add a fast-changing `@Published` property to `Player`.
- **Publishers** are named `<thing>Publisher` (`propertiesPublisher`, `periodicTimePublisher(forInterval:queue:)`), never fail (`Never`) unless failure is meaningful, deliver the current value upon subscription when they represent state, and are type-erased with `eraseToAnyPublisher()`.
- **Capability checks paired with actions**: provide `canX()` next to `x()` (`canSkipForward()`/`skipForward()`, `canInsert(_:before:)`/`insert(_:before:)`, `canReturnToPreviousItem()`/`returnToPreviousItem()`). Actions that can fail without an error return a `@discardableResult` `Bool`.
- **Factories over many initializers**: use static factory methods on the type for variants (`Asset.simple(url:configuration:)`, `Asset.custom(...)`, `Asset.encrypted(...)`; `PlayerItem.simple(url:metadata:trackerAdapters:)`).
- **Configuration structs**: options fixed at creation time go in an immutable configuration struct (`PlayerConfiguration`, `PlaybackConfiguration`). It has a `public static let default = Self()` and a memberwise `init` with defaults for every parameter. APIs take it as `configuration: X = .default`.
- **Extension points are protocols with associated types** (`AssetLoader` with `Input`/`Metadata`, `PlayerItemTracker` with `Configuration`/`Metadata`). Use `Void` when there is nothing to provide, and wrap them in adapters (`TrackerAdapter`) where type erasure is needed.
- **Enums for closed sets** (`Skip`, `RepeatMode`, `NavigationMode`), with associated values for parameters (`.smart(interval:)`). Avoid optional Booleans and optional collections (both are linted).
- **SwiftUI** integration uses views that take a `Player` (`VideoView(player:)`) and `View` modifiers (`bind(_:to:)`) rather than environment magic. Helper observable objects (`ProgressTracker`, `VisibilityTracker`) are meant to be held in the narrowest view scope.
- **Completion handlers** for user-triggered asynchronous actions default to a no-op (`completion: @escaping (Bool) -> Void = { _ in }`).

## Access control

- Group public members in `public extension Type { … }` blocks. Implementation details go in a separate, non-public `extension Type { … }` in the same file, or in `private` members.
- Use `@_spi(<Name>Private)` (`DownloaderPrivate`, `StandardConnectorPrivate`, `CoreBusinessPrivate`) only for symbols that sibling SRG SSR code must reach but that aren't part of the supported API. Ask before introducing a new SPI group.
- Prefer `internal` with `@testable import` in tests over making something public just for testing.

## Evolving API

- Pillarbox doesn't keep deprecated APIs around: renames and removals ship in the next major version and are listed under **Breaking Changes**. Point these changes out to the user explicitly.
- When an API is replaced, update the DocC articles, tutorials and the demo (`Demo/`) that use it in the same change.
