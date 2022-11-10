//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: Application

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                MediasTab()
                ShowcaseTab()
            }
        }
    }
}

// MARK: Tabs

private extension DemoApp {
    struct MediasTab: View {
        var body: some View {
            Navigation {
                ExamplesView()
            }
            .tabItem {
                Label("Examples", systemImage: "list.and.film")
            }
        }
    }

    struct ShowcaseTab: View {
        var body: some View {
            Navigation {
                ShowcaseView()
            }
            .tabItem {
                Label("Showcase", systemImage: "text.book.closed")
            }
        }
    }
}
