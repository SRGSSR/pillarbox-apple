# Pillarbox DocC catalogs

## Layout

PillarboxPlayer has the richest catalog:

```
Sources/Player/Player.docc/
├── PillarboxPlayer.md                          # landing page + Featured @Links grids + Topics
├── Extensions/                                 # <kebab-type>-extension.md for types with many members
│   ├── player-extension.md                     # ``PillarboxPlayer/Player``
│   ├── player-item-extension.md                # ``PillarboxPlayer/PlayerItem``
│   └── metrics-values-extension.md             # ``PillarboxPlayer/Metrics/Values`` (nested type)
├── Articles/
│   ├── playback-speed-article.md               # simple article
│   └── playback/                               # article with resources
│       ├── playback-article.md
│       └── playback-card.jpg
├── Images/                                     # images shared by the landing page and articles (player-intro.png, …)
├── Outlines/                                   # tutorial tables of contents
│   └── integrating-with-system-features/
│       ├── integrating-with-system-features.tutorial
│       ├── integrating-with-system-features-intro.png
│       └── integrating-with-system-features-1.jpg
└── Tutorials/
    └── supporting-airplay/
        ├── supporting-airplay.tutorial
        ├── supporting-airplay.jpg              # intro image
        ├── supporting-airplay-2-1.swift        # code at section 2, step 1
        ├── supporting-airplay-2-1.jpg          # matching screenshot
        └── supporting-airplay-2-1~dark.jpg     # dark mode variant
```

The other catalogs are smaller:

```
Sources/Analytics/Analytics.docc/
├── PillarboxAnalytics.md
├── setup-article.md                            # articles at the catalog root
├── page-views-article.md
├── events-article.md
└── user-consent-article.md

Sources/StandardConnector/StandardConnector.docc/PillarboxStandardConnector.md
Sources/CoreBusiness/CoreBusiness.docc/PillarboxCoreBusiness.md
Sources/Monitoring/Monitoring.docc/PillarboxMonitoring.md
Sources/Core/Core.docc/PillarboxCore.md             # abstract only, no Topics
Sources/Circumspect/Circumspect.docc/PillarboxCircumspect.md   # abstract only, no Topics
```

Follow the PillarboxPlayer layout (`Extensions/`, `Articles/`) when one of the other catalogs needs its first extension file or article. For PillarboxAnalytics, keep articles at the root unless the user decides otherwise.

## Extension files

The file name is the type name in kebab case followed by `-extension.md` (`PlayerItem` → `player-item-extension.md`, `Metrics.Values` → `metrics-values-extension.md`). Contents:

```markdown
# ``PillarboxPlayer/PlayerItem``

## Topics

### Creating a Player Item with an Asset Loader

- ``init(assetLoaderType:input:trackerAdapters:)``

### Creating a URL-Based Player Item

- ``simple(url:metadata:trackerAdapters:)``
- ``custom(assetProviderType:url:metadata:trackerAdapters:)``
```

- The title is ``Pillarbox<Module>/<TypeName>``. Nested types use ``Pillarbox<Module>/Outer/Inner``.
- Members are linked relative to the type, without a type prefix.
- Group headings are Title Case gerund phrases. A `####` subgroup can refine a group (`player-extension.md` has "#### Configuring Player Behavior" under "### Creating a Player"). Reuse the vocabulary already in the catalogs before inventing a new heading; `grep -h "^###" Sources/*/*.docc/Extensions/*.md | sort | uniq -c` lists it. Common headings are "Creating a <Type>", "Getting <X> Information", "Managing …", "Observing …", "Controlling Playback", "Seeking Through Media", "Binding to a Player" (for `bind(_:to:)` modifiers) and "Accessing Player Internals".
- Order groups from most to least commonly used. Initializers and factory methods usually come first.
- List every public member, including `body` for views and `==(_:_:)` when it's meaningful to compare instances. Leave out `hash(into:)`. Members that aren't listed end up in DocC's auto-generated sections.
- Read 2–3 existing extension files of similar types before you write one.

## Landing page Topics

`## Topics` in `Pillarbox<Module>.md` contains `### <Area>` groups. Examples are "Essentials", "Metadata", "System Integration", "Content Loading", "Tracking", "Metrics" and "User Interface" in PillarboxPlayer, and "Configuration", "Page Views", "Events" and "Streaming" in PillarboxAnalytics. Each group lists related articles first (`- <doc:...>`), then a blank line, then the types (``` - ``Type`` ```) in alphabetical order. When you add a public type, put it in the group that matches its area. If no group fits, ask the user rather than creating one.

Above `## Topics`, the PillarboxPlayer landing page also has a `### Featured` section and themed sections with `@Links(visualStyle: detailedGrid) { - <doc:...> }` grids. Only articles with a card image belong in these grids.

## Articles

```markdown
# Playback Speed

@Metadata {
    @PageColor(purple)
}

Control the pace at which content is played.

## Overview

<1–2 paragraphs: why the reader cares, which main type is involved>

### Adjust the playback speed programmatically

<explanation linking ``Player/playbackSpeed`` and other relevant symbols>

### Provide speed controls

...
```

- The file name is `<topic>-article.md`, and the article is referenced as `<doc:<topic>-article>`.
- The title is Title Case. The abstract is a single imperative sentence.
- Section headings are sentence case and imperative ("Adjust the playback speed programmatically", "Provide speed controls").
- `@PageColor` is the module color: purple for Player, blue for StandardConnector, yellow for CoreBusiness, red for Monitoring and green for Analytics.
- Featured articles have a card image, `@PageImage(purpose: card, source: <topic>-card, alt: "An image depicting …")`, with the image in the article's subfolder (`Articles/<topic>/<topic>-card.jpg`). Ask the user for the image; don't invent one.
- Use `> Tip:`, `> Important:`, `> Note:` and `> Warning:` asides, `@TabNavigator` (see `playback-article.md`, which has tabs for creating a player with no items, a single item or several items), and fenced `swift` code blocks where they help.
- Code samples must compile against the current API. Check every symbol you use in `Sources/`.
- Register the article in the landing page under the matching Topics group.

## Tutorials

- A tutorial lives in `Tutorials/<name>/<name>.tutorial` and is structured as `@Tutorial(time:)` → `@Intro(title:)` (with `@Image`) → `@Section(title:)` → `@ContentAndMedia` + `@Steps` → `@Step`.
- Steps reference code with `@Code(name: "ContentView.swift", file: <name>-<section>-<step>.swift)`, optionally with a nested `@Image(source: <name>-<section>-<step>, alt: "...")` screenshot. Screenshots come in light and `~dark` variants.
- Each step's code file is the **complete** file at that step: it repeats the previous step plus the change, so that DocC can show a diff. Keep consecutive steps minimally different.
- A tutorial is referenced from an outline in `Outlines/<outline>/<outline>.tutorial`, using `@Tutorials(name:)` → `@Chapter(name:)` → `@TutorialReference(tutorial: <name>)`. Symbols can link to tutorials with `<doc:<name>>` (for example `ProgressTracker` links `<doc:tracking-progress>`).

## Symbol link disambiguation

When a symbol is overloaded, a plain link is ambiguous and DocC emits a warning. The repo uses two styles:

- Type-signature disambiguation (preferred, readable): ``` ``seek(to:completion:)-(CMTime,_)`` ```, ``` ``SwiftUICore/View/bind(_:to:)-(ProgressTracker,_)`` ```
- Hash suffix (legacy; avoid in new docs): ``` ``SwiftUICore/View/bind(_:to:)-8fqem`` ```, ``` ``PlayerItemTracker/sessionIdentifier-329qf`` ```

Extensions on SwiftUI's `View` are linked through `SwiftUICore/View/...`, and extensions on other SwiftUI types through their module, for example ``` ``SwiftUI/Slider/init(progressTracker:label:minimumValueLabel:maximumValueLabel:onEditingChanged:)`` ```.
