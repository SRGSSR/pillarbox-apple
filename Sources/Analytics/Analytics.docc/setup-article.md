# Setup

@Metadata {
    @PageColor(green)
}

Set up tracking for your application.

## Overview

Before any measurements can occur, you must initialize a tracker with a configuration customized for your app.

### Obtain configuration information for your app

To configure tracking correctly, contact our digital analytics team to obtain the values for your product:

- Product name
- Site name
- Platform identifier

### Configure your application manifest

The app’s name and version are retrieved from the [app manifest](https://developer.apple.com/documentation/bundleresources/information_property_list). Update your `Info.plist` file with the following keys:

- `CFBundleName`: Set this to the product name provided for your app.
- `CFBundleShortVersionString`: Set this to the application version.

### Start tracking

To enable measurements, create a configuration with your business unit and the parameters received for your app. Then start the tracker singleton from your [application delegate](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) `application(_:didFinishLaunchingWithOptions:)` method:

```swift
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let configuration = Analytics.Configuration(
            vendor: .SRF,
            sourceKey: .production,
            appSiteName: "app-site-name",
            platformIdentifier: "app-platform-identifier"
        )
        try? Analytics.shared.start(with: configuration)

        // ...
    }
}
```

The source key determines the destination to which measurements are sent. Use `.production` for production builds and `.development` for development builds.

> Tip: For SwiftUI apps, use an [UIApplicationDelegateAdaptor](https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor) to register an application delegate.
