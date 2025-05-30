# Page Views

@Metadata {
    @PageColor(green)
}

Track user navigation within your app.

## Overview

Understanding how users navigate through your app is critical for improving user journeys and enhancing content discoverability.

The ``PillarboxAnalytics`` framework enables you to track page views as they appear on-screen. This provides valuable insights into user behavior, helping you optimize your app’s design and functionality.

> Important: Ensure tracking is properly set up before proceeding. Refer to the <doc:setup-article> article for details.

Page view tracking is supported in both SwiftUI and UIKit. Page views must in general be recorded when:

- A view is brought onto the screen.
- A view is revealed as part of another view being dismissed.
- The app returns from the background with a view visible.

### Define page view data

To track a page view, it must be associated with ``CommandersActPageView`` details, including a `name` and a `type`. Additionally, the `levels` attribute can be used to classify page views hierarchically. Note that this classification does not have to align with the page’s position in your view hierarchy.

> Note: Page views are exclusively supported by Commanders Act.

For inspiration, explore how [Play SRG products](https://srgssr-ch.atlassian.net/wiki/x/FwWhLw) utilize page views.

> Tip: Commanders Act fields must be properly mapped server-side. Check our [internal wiki](https://srgssr-ch.atlassian.net/wiki/x/zIZwLw) for available keys or contact the GD ADI team for further guidance on mapping and implementation.

### Automatically track page views in SwiftUI

Associate page views with SwiftUI views using the ``SwiftUICore/View/tracked(commandersAct:)`` modifier.

#### Example: Home view tracking

```swift
struct HomeView: View {
    var body: some View {
        VStack {
            // ...
        }
        .tracked(commandersAct: commandersAct)
    }
}

private extension HomeView {
    var commandersAct: CommandersActPageView {
        .init(
            name: "home", 
            type: "landing_page", 
            levels: ["main"]
        )
    }
}
```

### Automatically track page views in UIKit

For UIKit, use view controllers to represent screens and associate page view data by conforming to the ``PageViewTracking`` protocol.

#### Example: Home view controller tracking

```swift
final class HomeViewController: UIViewController {
    // ...
}

extension HomeViewController: PageViewTracking {
    var commandersActPageView: CommandersActPageView {
        .init(
            name: "home", 
            type: "landing_page", 
            levels: ["main"]
        )
    }

    var isTrackedAutomatically: Bool {
        true
    }
}
```

With ``PageViewTracking/isTrackedAutomatically-80h6v`` set to `true`, page views are recorded automatically when `viewDidAppear(_:)` is called.

> Tip: If page view data is unavailable in `viewDidAppear(_:)`, disable automatic tracking and manually trigger the page view later with ``UIKit/UIViewController/trackPageView()``.

### Manually track views

If automatic tracking is not suitable, you can manually trigger page views using ``Analytics/trackPageView(commandersAct:)``.

In general this is best avoided, though, since you are then responsible of correctly tracking appearing and revealed views, as well as views displayed when the app returns from background.

### Support automatic page view tracking in custom UIKit containers

For apps utilizing custom container view controllers, ensure these containers conform to the ``ContainerPageViewTracking`` protocol to enable compatibility with automatic tracking. Possible behaviors include:

- **Forward to All Children:** No additional configuration is required in this case.
- **Selective Forwarding:** Implement ``ContainerPageViewTracking`` to specify active children for measurements.

> Note: Standard UIKit containers are natively supported by the ``PillarboxAnalytics`` framework.
