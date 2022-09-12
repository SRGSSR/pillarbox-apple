//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

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

private struct MediasTab: View {
    var body: some View {
        NavigationStack {
            MediasView()
        }
        .tabItem {
            Label("Medias", systemImage: "list.and.film")
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
