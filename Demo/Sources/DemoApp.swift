//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Tabs

private struct MediasTab: View {
    var body: some View {
        Navigation {
            ExamplesView()
        }
        .tabItem {
            Label("Examples", systemImage: "list.and.film")
        }
    }
}

private struct SettingsTab: View {
    var body: some View {
        Navigation {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}

private struct ShowcaseTab: View {
    var body: some View {
        Navigation {
            ShowcaseView()
        }
        .tabItem {
            Label("Showcase", systemImage: "text.book.closed")
        }
    }
}

// MARK: Application

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                MediasTab()
                ShowcaseTab()
                SettingsTab()
            }
        }
    }
}
