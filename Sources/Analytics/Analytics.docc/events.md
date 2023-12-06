# Events

@Metadata {
    @PageColor(green)
}

Better understand how your app functionalities are used.

## Overview

As a product team you might to better understand which feature is popular and which one isn't.

The Analytics framework provides a way to send arbitrary events so that your analysts can better understand your users and help you lead your product in the right direction.

> Note: Events are supported by Commanders Act only.

### Send events

To send a custom event simply access the tracker singleton and call ``Analytics/sendEvent(commandersAct:)``. An event is described by a name and associated labels, so you could for example track the action associated with a favorite button as follows:

```swift
Analytics.shared.sendEvent(commandersAct: .init(
    name: "favorite",
    labels: [
        "event_value": "enabled"
    ]
))
```

For inspiration you should have a look at how [Play SRG products](https://confluence.srg.beecollaboration.com/display/SRGPLAY/Play+SRG+native+click+and+hidden+analytics+events) use events.

> Tip: Commanders Act fields need to be properly mapped server side. Please check our [internal wiki](https://confluence.srg.beecollaboration.com/pages/viewpage.action?pageId=13188692) for more information about available keys or contact the GD ADI team for more information.
