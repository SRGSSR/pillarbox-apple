# Setup

@Metadata {
    @PageColor(green)
}

Set up tracking for your application.

## Overview

Before any measurements can occur, you must initialize a tracker with a configuration customized for your app.

### Obtain configuration information for your app

To properly set up tracking, gather the following details:

- **Product Name:** This must be consistent across all platforms where your product is available.
- **App/Site Name:** This may vary between platforms.

The GD ADI team provides these values. For more details, consult our [internal wiki](https://confluence.srg.beecollaboration.com/display/INTFORSCHUNG/Guidance+Implementation+Apps).

### Configure your application manifest

The app’s name and version are retrieved from the [app manifest](https://developer.apple.com/documentation/bundleresources/information_property_list). Update your `Info.plist` file with the following keys:

- `CFBundleName`: Set this to the product name provided for your app.
- `CFBundleShortVersionString`: Set this to the application version.

### Start tracking

To enable measurements, you need to start the ``Analytics`` singleton. First, create a configuration using parameters specific to your app:

```swift
let configuration = Analytics.Configuration(
    vendor: .SRF,
    sourceKey: .productionSourceKey,
    appSiteName: "app-site-name"
)
```

Provide the **vendor** publishing the app, the appropriate **source key**, and the **site name** for your app.

> Note: Use `.productionSourceKey` for production apps. For development, set it to `.developmentSourceKey` to avoid contaminating production data.

Next, initialize the tracker singleton in your `application(_:didFinishLaunchingWithOptions:)` method, located in your [application delegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate):

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

> Tip: For SwiftUI apps, use an [UIApplicationDelegateAdaptor](https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor) to register an application delegate.
