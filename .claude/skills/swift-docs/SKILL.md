---
name: swift-docs
description: Write and maintain DocC documentation for the Pillarbox Swift package products (PillarboxPlayer, PillarboxStandardConnector, PillarboxCoreBusiness, PillarboxMonitoring, PillarboxAnalytics, PillarboxCore, PillarboxCircumspect) — `///` doc comments on Swift symbols, Topics extension files, landing pages, articles and tutorials in Sources/<Module>/<Module>.docc. Use this skill whenever the user asks to document, comment, explain in docs, write a DocC article, tutorial or guide, add doc comments, fix SwiftLint missing_docs warnings, organize the documentation, or after adding/renaming public API in Sources/ — even if they don't say "DocC" explicitly.
---

# Swift documentation for Pillarbox

Pillarbox's public API is documented with DocC. Users read it in Xcode Quick Help and on [Swift Package Index](https://swiftpackageindex.com/SRGSSR/pillarbox-apple), where the products listed in `.spi.yml` are published. Docs should therefore help someone *use* an API, not restate its signature. Consistency with the existing docs matters as much as correctness: new pages should read as if the author of `Sources/Player/Player.docc/PillarboxPlayer.md` wrote them.

The documentation lives in two places:

- **Source comments** (`///`) on symbols under `Sources/<Module>/`.
- **One catalog per product**, `Sources/<Module>/<Module>.docc/`:

  | Product | Catalog | Landing page | `@PageColor` |
  |---|---|---|---|
  | PillarboxPlayer | `Sources/Player/Player.docc` | `PillarboxPlayer.md` | `purple` |
  | PillarboxStandardConnector | `Sources/StandardConnector/StandardConnector.docc` | `PillarboxStandardConnector.md` | `blue` |
  | PillarboxCoreBusiness | `Sources/CoreBusiness/CoreBusiness.docc` | `PillarboxCoreBusiness.md` | `yellow` |
  | PillarboxMonitoring | `Sources/Monitoring/Monitoring.docc` | `PillarboxMonitoring.md` | `red` |
  | PillarboxAnalytics | `Sources/Analytics/Analytics.docc` | `PillarboxAnalytics.md` | `green` |
  | PillarboxCore | `Sources/Core/Core.docc` | `PillarboxCore.md` | none |
  | PillarboxCircumspect | `Sources/Circumspect/Circumspect.docc` | `PillarboxCircumspect.md` | none |

  Each catalog may contain:
  - `Pillarbox<Module>.md`: the landing page. Its `## Topics` section groups articles and top-level public types.
  - `Extensions/<kebab-type-name>-extension.md` (currently only PillarboxPlayer): organizes the members of a type that has many of them into topic groups.
  - Articles: in `Articles/` (PillarboxPlayer) or at the catalog root (PillarboxAnalytics), and in a subfolder when they have card images.
  - `Tutorials/` and `Outlines/` (PillarboxPlayer only): step-by-step tutorials.

`PillarboxStreams` is test-only and is not documented.

## Workflow

Figure out which of these the user wants (often several), then follow the relevant section. Before writing anything, read 2–3 neighbouring files of the same kind in the **same module**, so that the tone and structure match. The conventions below are a summary; the existing files are the source of truth.

### 1. Doc comments

Read `references/comment-style.md` for the full conventions and examples. The essentials:

- Document every `public`/`open` symbol. SwiftLint's `missing_docs` rule enforces it. Internal symbols are documented only when their purpose isn't obvious from the name; don't blanket-comment internals the user didn't ask about.
- Start with a single-sentence summary that ends with a period, phrased the way the existing docs do it:
  - Types: noun phrase ("An item that can be inserted into a ``Player`` for playback.").
  - Properties: noun phrase ("The current item.").
  - Methods: third-person verb ("Inserts an item before another one.").
  - Initializers: "Creates <a noun>." ("Creates a player with a given item queue.", "Creates a view displaying video content.").
  - Booleans: "A Boolean describing whether…".
- Add discussion paragraphs only when there's something worth saying: preconditions, side effects, behavior in edge cases (`nil`, empty, out of range), threading (Player APIs are main-thread only, and some tracker callbacks run on a background queue), and how the symbol relates to other APIs. Don't pad.
- Use `- Parameter name:` (single) or `- Parameters:` (multiple), and `- Returns:` for non-`Void` functions. Describe meaning, not type.
- Link other symbols with double backticks (` ``Player/play()`` `) and use single backticks for code that isn't a symbol.
- Public implementations of protocol requirements that need no explanation are marked `// swiftlint:disable:next missing_docs` rather than documented. Examples are `PlayerItemTracker` conformances in `MetricsTracker`, `CommandersActTracker` and `ComScoreTracker`, and `Publisher`/`Subject` conformances in `PillarboxCore`. Keep that pattern.
- Never change code while documenting. If you notice a bug or a naming issue, mention it to the user instead.

### 2. Topics curation

Read `references/catalog.md` for the file formats, the grouping vocabulary and symbol-link disambiguation.

- Every public top-level type should appear in a `### Group` under `## Topics` in its module's landing page. PillarboxCore and PillarboxCircumspect landing pages currently have no Topics section, so ask the user before adding one.
- Extension files exist only for types whose members benefit from explicit grouping. Currently these are `Player`, `PlayerItem`, `Asset`, `Metrics`, `Metrics/Values`, `ProgressTracker`, `VisibilityTracker` and `SystemVideoView`, all in PillarboxPlayer. When you add or change public members of one of these types, update its extension file so the new member appears in the right group. Members that aren't listed fall into an auto-generated section, which looks unfinished. Suggest a new extension file when a type grows enough members that DocC's default grouping becomes unhelpful; don't create one for every type.

### 3. Articles

Read `references/catalog.md` (Articles section) and at least one existing article in the same module before writing. Articles are task-oriented ("Control the pace at which content is played.") and use `@Metadata { @PageColor(<module color>) }`. They start with an abstract sentence and `## Overview`, followed by `###`/`##` sections with imperative headings ("Adjust the playback speed programmatically"). Link symbols generously, and link related articles with `<doc:article-id>`. Register a new article in the landing page's Topics. If it's a major topic, ask the user whether it should also go in a `@Links` grid.

Article code samples should be realistic SwiftUI using Pillarbox's actual API. Check signatures in `Sources/` rather than guessing. Articles in a module can link to symbols in that module only; refer to other products by name, for example "the PillarboxCoreBusiness framework".

### 4. Tutorials (PillarboxPlayer only)

Read `references/catalog.md` (Tutorials section). Each step's code file contains the complete file at that step, so an API change must be applied to every step file that uses it. Screenshots can't be produced here. List the images that need to be retaken for the user.

## Verifying

- `swiftlint lint --quiet --strict --only-rule missing_docs` confirms that no public symbol is left undocumented. `make check-quality` runs SwiftLint, and also `markdownlint`, which checks the `.md` files in the catalogs.
- `xcodebuild docbuild -scheme Pillarbox<Module> -destination 'generic/platform=iOS' -skipPackagePluginValidation` resolves every link. Warnings mentioning "doesn't exist" or "ambiguous" are broken or under-disambiguated links. Dependencies (for example swift-collections) emit warnings of their own, so filter the output with `grep -v SourcePackages`. The build needs simulator services and network access, so it may have to run outside the Bash sandbox. It's slow (a full build), so offer to run it rather than running it unasked after small changes.

## Reporting back

Summarize what you documented (files and symbol counts), anything you deliberately skipped and why, and any open questions, such as behavior you couldn't determine from the code. Guessing at behavior in published docs is worse than leaving a question for the user.
