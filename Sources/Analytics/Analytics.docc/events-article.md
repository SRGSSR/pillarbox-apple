# Events

@Metadata {
    @PageColor(green)
}

Gain insights into how your app’s features are being utilized.

## Overview

As a product team, understanding which features are popular and which are underutilized is essential for informed decision-making.

The ``PillarboxAnalytics`` framework enables you to send custom events, allowing your analysts to better understand user behavior and guide your product strategy effectively.

> Important: Ensure tracking is properly set up before proceeding. Refer to the <doc:setup-article> article for detailed instructions.

### Send events

To send a custom event, use the tracker singleton and invoke the ``Analytics/sendEvent(commandersAct:)`` method.

> Note: Events are exclusively supported by Commanders Act.

An event consists of a name and associated labels. For example, tracking the action of a “favorite” button can be achieved as follows:

```swift
Analytics.shared.sendEvent(commandersAct: .init(
    name: "favorite",
    labels: [
        "event_value": "enabled"
    ]
))
```

For inspiration, explore how [Play SRG products](https://confluence.srg.beecollaboration.com/display/SRGPLAY/Play+SRG+native+click+and+hidden+analytics+events) utilize events.

> Tip: Commanders Act fields must be properly mapped server-side. Check our [internal wiki](https://confluence.srg.beecollaboration.com/pages/viewpage.action?pageId=13188692) for available keys or contact the GD ADI team for further guidance on mapping and implementation.
