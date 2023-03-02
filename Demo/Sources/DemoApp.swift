//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct MediasTab: View {
    var body: some View {
        NavigationStack {
            ExamplesView()
        }
        .tabItem {
            Label("Examples", systemImage: "film")
        }
    }
}

private struct ListsTab: View {
    var body: some View {
        NavigationStack {
            ListsView()
        }
        .tabItem {
            Label("Lists", systemImage: "list.and.film")
        }
    }
}

private struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}

private struct ShowcaseTab: View {
    var body: some View {
        NavigationStack {
            ShowcaseView()
        }
        .tabItem {
            Label("Showcase", systemImage: "text.book.closed")
        }
    }
}

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                MediasTab()
                ListsTab()
                ShowcaseTab()
                SettingsTab()
            }
        }
    }
}
