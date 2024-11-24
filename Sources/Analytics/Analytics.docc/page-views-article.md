# Page Views

@Metadata {
    @PageColor(green)
}

Identify where users navigate within your app.

## Overview

As a product team you need to better understand where users navigate within your app. The ``PillarboxAnalytics`` framework provides a way to track views as they are brought on screen. This makes it possible to improve on user journeys and make your content more discoverable.

> Important: Tracking must be properly setup first. Please refer to <doc:setup-article> for more information.

Helpers are available to record page views, whether your view hierarchy is managed with UIKit or SwiftUI.

> Note: A page view is recorded when a view is brought on screen, when it is revealed as part of another view being dismissed or when the app returns from background with the view visible.

### Decide which data needs to be sent

Tracking a page view requires a view to be associated with ``ComScorePageView``, respectively ``CommandersActPageView`` information. Both types have mandatory fields as well as optional information:

- comScore requires only a `name` to be provided.
- Commanders Act requires a `name` and a `type` to be provided. You can also use `levels` to classify your page views hierarchically. This classification does not need to represent where the view is located in your view hierarchy, though.

For inspiration you should have a look at how [Play SRG products](https://confluence.srg.beecollaboration.com/display/SRGPLAY/Play+SRG+native+page+view+analytic+events) define page views.

> Tip: Commanders Act fields need to be properly mapped server-side. Please check our [internal wiki](https://confluence.srg.beecollaboration.com/pages/viewpage.action?pageId=13188692) for more information about available keys or contact the GD ADI team for more information.
>
> You should not add custom information to comScore page views as undefined fields will be ignored server-side anyway.

### Track page views in SwiftUI

To associate a page view with a SwiftUI view, simply apply the ``SwiftUICore/View/tracked(comScore:commandersAct:)`` modifier. You could for example track a home view as follows:

```swift
struct HomeView: View {
    var body: some View {
        VStack {
            // ...
        }
        .tracked(comScore: comScore, commandersAct: commandersAct)
    }
}
```

with page view data defined in a private extension:

```swift
private extension HomeView {
    var comScore: ComScorePageView {
        .init(name: "home")
    }

    var commandersAct: CommandersActPageView {
        .init(
            name: "home", 
            type: "landing_page", 
            levels: ["main"]
        )
    }
}
```

### Track page views in UIKit

View controllers commonly represent screens in a UIKit application. The ``PillarboxAnalytics`` framework provides a streamlined way to associate page view data with a view controller by having it conform to the ``PageViewTracking`` protocol:

```swift
final class HomeViewController: UIViewController {
    // ...
}

extension HomeViewController: PageViewTracking {
    var comScorePageView: ComScorePageView {
        .init(name: "home")
    }

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

With automatic tracking enabled page views will be recorded for `PageViewTracking`-conforming view controllers without any additional work. Note that this process occurs when a view controller `viewDidAppear(_:)` method is called.

> Tip: If your view controller lacks the required data when its associated view appears you can disable automatic tracking and manually trigger a page view later using ``UIKit/UIViewController/trackPageView()``.

### Implement page view tracking support in custom UIKit containers

If your application uses custom view controller containers, and if you want to use automatic tracking, be sure to have them conform to the ``ContainerPageViewTracking`` protocol so that automatic page views are correctly propagated throughout your application view controller hierarchy.

Only a container can namely decide for which child (or children) page views should be recorded:

- If page views must be automatically forwarded to all children of a container no additional work is required.
- If page views must be automatically forwarded to only selected children, though, then a container must conform to the `ContainerPageViewTracking` protocol to declare which children must be considered active for measurements.

> Tip: The ``PillarboxAnalytics`` framework provides native support for standard UIKit containers without any additional work.

### Trigger page views manually

Whether your application is implemented in SwiftUI, UIKit or a combination of both, you can always trigger a page view manually with ``Analytics/trackPageView(comScore:commandersAct:)``.

In general this is best avoided, though, since you are then responsible of correctly tracking appearing and revealed views, as well as views displayed when the app returns from background.
