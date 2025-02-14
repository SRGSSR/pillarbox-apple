# User Consent

@Metadata {
    @PageColor(green)
}

Take into account user choices about the data they are willing to share.

## Overview

The ``PillarboxAnalytics`` framework does not directly implement user consent management but provides a way to forward user consent choices to the Commanders Act and comScore SDKs so that user wishes can be properly taken into account at the data processing level.

> Note: Do not worry if you observe analytics-related network traffic with a proxy tool like [Charles](https://www.charlesproxy.com). The ``PillarboxAnalytics`` framework still sends data but user consent is transmitted in each request payload for server-side processing.

### Setup an analytics data source

User consent is sent with each analytic network call in globals set through a data source associated with the ``Analytics`` singleton.

To send user consent choices you must therefore register an ``AnalyticsDataSource`` when starting the tracker. The app delegate from which the tracker must be started is usually a perfect candidate for this role:

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let configuration = Analytics.Configuration(
            vendor: .SRF,
            sourceKey: .production,
            appSiteName: "app-site-name"
        )
        try? Analytics.shared.start(with: configuration, dataSource: self)

        // ...
    }
}
```

Read the <doc:setup-article> article for more information about tracking setup.

### Provide user content choices

Implement the ``AnalyticsDataSource`` to provide user consent choices in globals:

```swift
extension AppDelegate: AnalyticsDataSource {
    var comScoreGlobals: ComScoreGlobals {
        .init(consent: .accepted, labels: [
           // ...
        ])
    }

    var commandersActGlobals: CommandersActGlobals {
        .init(consentServices: ["service1", "service2", "service3"], labels: [
            // ...
        ])
    }
}
```

In the example above user consent has been hardcoded but a real implementation should check local user consent data to provide parameters matching the current user choices.

> Warning: ``AnalyticsDataSource`` methods are called with each event sent. Your implementation should therefore be as efficient as possible.
