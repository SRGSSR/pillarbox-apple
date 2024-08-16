# Setup

@Metadata {
    @PageColor(green)
}

Setup tracking for your application.

## Overview

Before any measurements can take place you must start a tracker with a configuration tailored for your app.

### Obtain configuration information for your app

The following information is required to properly setup tracking for your app:

- The product name, identical for all platforms on which your product is available.
- The app/site name, which might differ between platforms.

Values suitable for your app are delivered by the GD ADI team. Please refer to our [internal wiki](https://confluence.srg.beecollaboration.com/display/INTFORSCHUNG/Guidance+Implementation+Apps) for more information.

### Configure your application manifest

The name and version of your application are retrieved from the [app manifest](https://developer.apple.com/documentation/bundleresources/information_property_list). You must configure your `Info.plist` file so that it contains the following key-value pairs:

- `CFBundleName` must contain the product name obtained for your app.
- `CFBundleShortVersionString` must contain the application version.

### Start tracking

The ``Analytics`` singleton needs to be started before any measurements can take place. First create a configuration with parameters tailored to your app:

```swift
let configuration = Analytics.Configuration(
    vendor: .SRF,
    sourceKey: .productionSourceKey,
    appSiteName: "app-site-name"
)
```

You must provide the vendor publishing the app, a source key as well as the site name your received for your app.

> Note: The source key must be `.productionSourceKey` for apps in production. During development you should set it to `.developmentSourceKey` to avoid polluting measurements associated with the production source key.

Once you have a configuration simply start the tracker singleton from the `application(_:didFinishLaunchingWithOptions:)` implementation of your [application delegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate):

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
        try? Analytics.shared.start(with: configuration)
        
        // ...
    }
}
```

> Tip: SwiftUI apps must use an [UIApplicationDelegateAdaptor](https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor) to register an application delegate.
