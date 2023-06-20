//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct ExamplesTab: View {
    var body: some View {
        RoutedNavigationStack {
            ExamplesView()
        }
        .tabItem {
            Label("Examples", systemImage: "film")
        }
    }
}

private struct ContentListsTab: View {
    var body: some View {
        RoutedNavigationStack {
            ContentListsView()
        }
        .tabItem {
            Label("Lists", systemImage: "list.and.film")
        }
    }
}

private struct SettingsTab: View {
    var body: some View {
        RoutedNavigationStack {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}

private struct SearchTab: View {
    var body: some View {
        RoutedNavigationStack {
            SearchView()
        }
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
    }
}

private struct ShowcaseTab: View {
    var body: some View {
        RoutedNavigationStack {
            ShowcaseView()
        }
        .tabItem {
            Label("Showcase", systemImage: "text.book.closed")
        }
    }
}

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                ExamplesTab()
                ShowcaseTab()
                ContentListsTab()
                SearchTab()
                SettingsTab()
            }
        }
    }
}
