---
paths:
  - "**/*.swift"
---

# Code style

SwiftLint runs in strict mode with a large set of opt-in rules (`.swiftlint.yml`), so a warning fails `make check-quality` and the pre-commit hook. Read neighbouring code and match it. The points below are what linting doesn't fully cover, or what is easy to get wrong.

## Files

- Every Swift file starts with the license header, followed by a blank line:

  ```swift
  //
  //  Copyright (c) SRG SSR. All rights reserved.
  //
  //  License information is available from the LICENSE file.
  //
  ```

- Imports are sorted alphabetically. In tests, `@testable import` comes first, followed by a blank line.
- One main type per file, named after it. Type extensions split by feature use `Type+Feature.swift` (`Player+Seek.swift`). Extensions on system types go in `<Module>/Extensions/<SystemType>.swift` (`AVPlayerItem.swift`, `CMTime.swift`).
- Indent with 4 spaces, use LF line endings and keep no trailing whitespace (`.editorconfig`). Lines warn at 160 characters, but code and comments are usually wrapped around 120.

## Formatting

- `else`, `catch` and similar keywords go on a new line after a closing brace:

  ```swift
  if duration.isIndefinite {
      ...
  }
  else {
      return true
  }
  ```

- Short guards stay on one line: `guard let item else { return near(time) }`.
- Use implicit returns for single-expression bodies, and shorthand optional binding (`if let item`).
- Multi-line arguments, parameters and collection literals put one item per line with the closing bracket on its own line, and require a trailing comma in collections. Multi-line function chains put one call per line:

  ```swift
  currentItemPublisher()
      .map { ... }
      .switchToLatest()
      .removeDuplicates()
      .eraseToAnyPublisher()
  ```

- `switch` cases each sit on their own line (`switch_case_on_newline`).

## Idioms

- Use `Self` in static references and for the type of `self` (`public static let default = Self()`).
- Don't write `self.` where it can be omitted (`redundant_self`), except in initializers that assign same-named parameters.
- Capture `[weak self]` in escaping closures that outlive a call. Never use `unowned`. Delegates are `weak`.
- Use key paths over trivial closures (`.map(\.id)`), `isEmpty` over `count == 0`, `first(where:)` over `filter().first`, `reduce(into:)` for accumulations, and `toggle()` for Booleans.
- Name Booleans `isX`/`hasX`/`canX`/`shouldX`/`allowsX`. Don't use optional Booleans or optional collections.
- Implement reactive logic with Combine pipelines (`Sources/Player/Publishers/`). Subjects are `private` (`private_subject`); when a subject must be visible inside the module, mark the line `// swiftlint:disable:next private_subject`.
- Use `swiftlint:disable:next <rule>` locally and sparingly, never file-wide.
- Avoid `// MARK:` noise. Separate concerns with extensions and files instead.
- Write comments for *why*, not *what*, like `// If the stream supports stepping use an exact position. This makes it possible…`.

## Tests

- XCTest with Nimble (`expect(...).toEventually(...)`, which the linter requires over `XCTAssert`) and PillarboxCircumspect publisher expectations (`expectAtLeastEqualPublished`, …).
- Test classes are `final class <Subject>Tests: TestCase` (the module's tolerant `TestCase`) or `XCTestCase`, one class per file, with `testXxx()` methods. They play streams from `PillarboxStreams` (`Stream.onDemand.url`, …), which requires `make test-streams-start`.
- With the module's `TestCase` base class, `toAlways`/`toNever` default to the 20-second timeout, so always pass an explicit `until:`.
