# User consent

@Metadata {
    @PageColor(green)
}

Take into account user choices about the data they are willing to share.

## Overview

The Analytics framework does not directly implement user consent management but provides a way to forward user consent settings to the Commanders Act and comScore SDKs so that user wishes can be properly taken into account at the data processing level.

> Note: If you observe network traffic with a proxy tool like Charles you can still observe that both the Commanders Act and comScore SDKs still perform network calls, even if the user does not provide any consent. This is expected behavior as user consent settings, send as part of network request payloads, will be taken into account server-side.

### Setup an analytics data source

Provide an ``AnalyticsDataSource`` when starting the tracker. The app delegate from which the tracker must be started is a natural candidate for this role:

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication, 
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let configuration = Analytics.Configuration(
            vendor: .SRF,
            sourceKey: .productionSourceKey,
            appSiteName: "app-site-name"
        )
        try? Analytics.shared.start(with: configuration, dataSource: self)
        
        // ...
    }
}
```

See <doc:setup> for more information about tracking setup.

### Provide user content information in data source global labels

Implement the ``AnalyticsDataSource``, which lets you return global analytics labels for comScore and Commanders Act respectively, as well as associated user consent information. With the application delegate as data source the implementation would look like:

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

In the example above user consent has been hardcoded but a real implementation should check local user consent information to provide parameters matching the current settings.

> Warning: ``AnalyticsDataSource`` methods are called before any event is sent. Your implementation should therefore be as efficient as possible.
