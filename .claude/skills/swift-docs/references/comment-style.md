# Doc comment style

These examples are taken from `Sources/`. When in doubt, grep for a similar symbol in the same module and copy its shape.

## Types

A summary noun phrase, followed by a short discussion of the role of the type and how to obtain or use it. Link to the APIs a reader needs next. Longer type docs can contain a `## Usage` section with a numbered list of steps (see `ProgressTracker`).

```swift
/// An item that can be inserted into a ``Player`` for playback.
///
/// Convenience initializers are provided for different types of assets:
///
/// - Simple assets which can be played from a simple URL.
/// - Custom assets which require custom resource loading.
/// - Encrypted assets which require a FairPlay content key session.
public final class PlayerItem: Identifiable {
```

Within its own type's comment, the type name is written with single backticks (`` `ProgressTracker` ``). Other types are linked with double backticks.

## Properties

A noun phrase. Add a sentence when setting the property has side effects, when the value can be `nil` and why, or when there's a precondition.

```swift
/// The current item.
///
/// This method can be used to replace the current item with an item not in the current ``items``. If the item set
/// is identical to the current item a skip to its default position is performed instead.
@Published public var currentItem: PlayerItem? {
```

```swift
/// A Boolean describing whether the player is currently buffering.
```

For `Bool` properties, use "A Boolean describing whether…". This is the most common form in the codebase. Older comments use variants such as "A Boolean value that indicates whether…" and "A Boolean setting whether…"; don't add new ones.

## Methods

A summary with a third-person verb. Use `- Parameter` for one parameter, `- Parameters:` with an indented list for several, and `- Returns:` whenever the return type isn't `Void`. For `Bool` returns, especially `@discardableResult` ones, use the form "`true` iff …". Behavioral notes can follow the parameter list.

```swift
/// Inserts an item before another one.
///
/// - Parameters:
///   - item: The item to insert.
///   - beforeItem: The item before which insertion must take place. Pass `nil` to insert the item at the front
///     of the queue.
/// - Returns: `true` iff the item could be inserted.
///
/// Does nothing if the item already belongs to the queue.
@discardableResult
func insert(_ item: PlayerItem, before beforeItem: PlayerItem?) -> Bool {
```

Static factory methods use "Returns <a noun>.":

```swift
/// Returns a simple asset playable from a URL.
///
/// - Parameters:
///   - url: The URL to be played.
///   - configuration: The configuration to apply to the asset.
/// - Returns: The asset.
public static func simple(url: URL, configuration: PlaybackConfiguration = .default) -> Self {
```

## Initializers

"Creates <noun>." followed by the parameters. Behavioral discussion, such as the failure conditions of a failable initializer, can come after the parameter list.

```swift
/// Creates a player with a given item queue.
///
/// - Parameters:
///   - items: The items to be queued initially.
///   - configuration: The configuration to apply to the player.
public init(items: [PlayerItem] = [], configuration: PlayerConfiguration = .default) {
```

## Enum cases

A short noun phrase or sentence per case.

## Protocol requirements

For protocols meant to be implemented by clients (`AssetLoader`, `PlayerItemTracker`, `PictureInPictureDelegate`, …), document what the implementation must do and **when and on which thread** it is called:

```swift
/// > Important: This method is called on a background serial queue.
```

Implementations of these requirements in Pillarbox's own types are marked `// swiftlint:disable:next missing_docs` (see `MetricsTracker`).

## SwiftUI views and modifiers

Describe what the view displays and how it behaves, and say what the caller has to provide (bindings, environment, a ``Player``). For modifiers, describe the effect on the modified view.

```swift
/// Creates a view displaying video content.
///
/// - Parameter player: The player whose content is displayed.
public init(player: Player) {
```

```swift
public extension View {
    /// Binds a progress tracker to a player.
    ///
    /// - Parameters:
    ///   - progressTracker: The progress tracker to bind.
    ///   - player: The player to observe.
    func bind(_ progressTracker: ProgressTracker, to player: Player?) -> some View {
```

## Asides

Use DocC asides sparingly, with one idea each:

```swift
/// > Note: Limits are ignored when casting to an AirPlay receiver.
/// > Important: This method must only be started in response to some form of user interaction.
/// > Warning: Progress trackers should be associated with local view scopes to avoid unnecessary view body refreshes.
```

## Links

- Use ``Type``, ``Type/member`` and ``Type/method(_:label:)``, including argument labels for methods.
- Overloads need disambiguation; see `catalog.md`.
- Link to articles and tutorials with `<doc:state-observation-article>` and `<doc:tracking-progress>`.
- Link external Apple types to developer.apple.com with Markdown, for example [`ObservableObject`](https://developer.apple.com/documentation/combine/observableobject).
- Link to Apple docs or the HIG when a reader needs background on AVFoundation, FairPlay, AirPlay or Picture in Picture concepts.

## Writing tips

- Wrap comment lines at 120 characters, like the surrounding code. SwiftLint's `line_length` warns at 160.
- Explain *what the caller gets and when to use it*. Don't restate the signature ("The `foo` parameter of type `Int`").
- Mention units (seconds, `CMTime`), ranges, and defaults when they matter.
- Use American English and the Oxford comma, as in the existing docs.
- Don't document behavior you inferred but couldn't confirm in the code. Ask the user instead.
