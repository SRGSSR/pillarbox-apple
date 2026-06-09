//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    @StateObject private var router = Router()
    @StateObject private var downloaders: Downloaders = {
        var downloaders: [any DownloadManagement] = [
            Downloader(
                assetLoaderType: DemoAssetLoader.self,
                mapperType: DemoAssetMapper.self,
                configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads"),
                store: DemoAssetDownloadStore(fileName: "file_downloads.json")
            )
        ]
        if #available(iOS 17, *) {
            downloaders.append(Downloader(
                assetLoaderType: URNAssetLoader.self,
                mapperType: URNAssetMapper.self,
                configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"),
                store: URNAssetDownloadStore()
            ))
        }
        return .init(downloaders: downloaders)
    }()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                examplesTab()
                showcaseTab()
                contentListsTab()
                searchTab()
#if DEBUG && os(iOS)
                downloadsTab()
#endif
                settingsTab()
            }
            .modal(item: $router.presented) { presented in
                presented.view()
            }
            .environmentObject(router)
            .environmentObject(downloaders)
        }
    }

    private func examplesTab() -> some View {
        RoutedNavigationStack(keyPath: \.examplesPath) {
            ExamplesView()
        }
        .tabItem {
            Label("Examples", systemImage: "film")
        }
    }

    private func showcaseTab() -> some View {
        RoutedNavigationStack(keyPath: \.showcasePath) {
            ShowcaseView()
        }
        .tabItem {
            Label("Showcase", systemImage: "text.book.closed")
        }
    }

    private func contentListsTab() -> some View {
        RoutedNavigationStack(keyPath: \.contentListsPath) {
            ContentListsView()
        }
        .tabItem {
            Label("Lists", systemImage: "list.and.film")
        }
    }

    private func searchTab() -> some View {
        RoutedNavigationStack(keyPath: \.searchPath) {
            SearchView()
        }
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
    }

#if DEBUG && os(iOS)
    private func downloadsTab() -> some View {
        RoutedNavigationStack(keyPath: \.downloadsPath) {
            DownloadsView()
        }
        .tabItem {
            Label("Downloads", systemImage: "square.and.arrow.down")
        }
    }
#endif

    private func settingsTab() -> some View {
        RoutedNavigationStack(keyPath: \.settingsPath) {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gearshape.fill")
        }
    }
}
