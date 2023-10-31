//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    @StateObject private var router = Router()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                examplesTab()
                showcaseTab()
                contentListsTab()
                searchTab()
                settingsTab()
            }
            .modal(item: $router.presented) { presented in
                presented.view()
            }
            .environmentObject(router)
        }
    }

    @ViewBuilder
    private func examplesTab() -> some View {
        RoutedNavigationStack(keyPath: \.examplesPath) {
            ExamplesView()
        }
        .tabItem {
            Label("Examples", systemImage: "film")
        }
    }

    @ViewBuilder
    private func showcaseTab() -> some View {
        RoutedNavigationStack(keyPath: \.showcasePath) {
            ShowcaseView()
        }
        .tabItem {
            Label("Showcase", systemImage: "text.book.closed")
        }
    }

    @ViewBuilder
    private func contentListsTab() -> some View {
        RoutedNavigationStack(keyPath: \.contentListsPath) {
            ContentListsView()
        }
        .tabItem {
            Label("Lists", systemImage: "list.and.film")
        }
    }

    @ViewBuilder
    private func searchTab() -> some View {
        RoutedNavigationStack(keyPath: \.searchPath) {
            SearchView()
        }
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
    }

    @ViewBuilder
    private func settingsTab() -> some View {
        RoutedNavigationStack(keyPath: \.settingsPath) {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}
