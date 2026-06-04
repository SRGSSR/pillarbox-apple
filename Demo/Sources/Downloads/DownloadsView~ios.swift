//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxPlayer

import PillarboxCoreBusiness

import SwiftUI

@available(iOS 17.0, *)
struct DownloadsView: View {
    @StateObject private var urlDownloader = Downloader(
        assetLoaderType: DemoAssetLoader.self,
        configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads"),
        store: DemoAssetDownloadStore(fileName: "file_downloads.json")
    )
    @StateObject private var urnDownloader = Downloader(
        assetLoaderType: URNAssetLoader.self,
        configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"),
        store: URNAssetDownloadStore()
    )
    @EnvironmentObject private var router: Router

    private var downloads: [Download] {
        urlDownloader.downloads + urnDownloader.downloads
    }

    var body: some View {
        ZStack {
            if !downloads.isEmpty {
                mainView()
            }
            else {
                emptyView()
            }
        }
        .animation(.defaultLinear, value: urlDownloader.downloads)
        .toolbar {
            ToolbarItem {
                removeAllButton()
            }
            ToolbarItem {
                menu()
            }
        }
        .navigationTitle("Downloads")
    }

    private func mainView() -> some View {
        List {
            list(for: urlDownloader)
            list(for: urnDownloader)
        }
    }

    private func list<S>(for downloader: Downloader<S>) -> some View where S: AssetDownloadStore {
        ForEach(downloader.downloads, id: \.self) { download in
            DownloadCell(download: download) {
                if let item = downloader.playerItem(for: download) {
                    router.presented = .player(media: .init(title: download.metadata.title ?? "Untitled", type: .item(item)))
                }
            }
        }
        .onDelete { indexes in
            for index in indexes.reversed() {
                downloader.removeDownload(downloader.downloads[index])
            }
        }
    }

    private func emptyView() -> some View {
        UnavailableView {
            Label {
                Text("No downloads.")
            } icon: {
                Image(systemName: "square.and.arrow.down")
            }
        }
    }

    private func menu() -> some View {
        Menu {
            // Warning: Use /ww/ streams only since /ch/-ones are AES-encrypted and cannot be played offline.
            addDownloadButton(
                title: "Short video",
                url: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8"
            )
            addDownloadButton(
                title: "Medium video",
                url: "https://rts-vod-amd.akamaized.net/ww/cc16c4b0-1c15-326d-958b-faad09e216c1/ffc39d4f-eb00-3979-a5bd-0e3b93b99073/master.m3u8"
            )
            addDownloadButton(
                title: "Long video",
                url: "https://rts-vod-amd.akamaized.net/ww/14970442/4dcba1d3-8cc8-3667-a7d2-b3b92c4243d9/master.m3u8"
            )
            addDownloadButton(
                title: "MP3",
                url: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3"
            )
            addDownloadButton(
                title: "Final de cœur à cœur 2025 - MERCI",
                urn: "urn:rts:video:538114c0-8855-3b60-9965-981838532d09"
            )
        } label: {
            Image(systemName: "plus")
        }
    }

    private func addDownloadButton(title: String, url: URL) -> some View {
        Button {
            urlDownloader.addDownload(for: .init(title: title, url: url))
        } label: {
            Text(title)
        }
    }

    private func addDownloadButton(title: String, urn: String) -> some View {
        Button {
            urnDownloader.addDownload(for: .init(urn: urn, server: .production, configuration: .default))
        } label: {
            Text(title)
        }
    }

    @ViewBuilder
    private func removeAllButton() -> some View {
        Button {
            urlDownloader.removeAllDownloads()
            urnDownloader.removeAllDownloads()
        } label: {
            Image(systemName: "trash")
        }
    }
}

#Preview {
    NavigationStack {
        if #available(iOS 17.0, *) {
            DownloadsView()
        }
    }
}

#endif
