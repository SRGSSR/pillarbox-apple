//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var downloader: DemoDownloader
    @EnvironmentObject private var router: Router

    var body: some View {
        ZStack {
            if !downloader.downloads.isEmpty {
                mainView()
            }
            else {
                emptyView()
            }
        }
        .animation(.defaultLinear, value: downloader.downloads.map(\.id))
        .toolbar {
            removeAllButton()
        }
        .navigationTitle("Downloads")
    }

    private func mainView() -> some View {
        List(downloader.downloads) { download in
            DownloadCell(download: download) {
                if let media = media(from: download) {
                    router.presented = .player(media: media)
                }
            }
            .swipeActions {
                button(systemImage: "trash", color: .red) { downloader.removeDownload(download) }
                button(systemImage: "arrow.counterclockwise", action: download.restart)
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

    @ViewBuilder
    private func removeAllButton() -> some View {
        if !downloader.downloads.isEmpty {
            Button {
                downloader.removeAllDownloads()
            } label: {
                Image(systemName: "trash")
            }
            Button(action: openPlaylist) {
                Image(systemName: "rectangle.stack.badge.play")
            }
            .accessibilityLabel("Open as playlist")
        }
    }

    private func media(from download: Download) -> Media? {
        guard let item = downloader.playerItem(for: download) else { return nil }
        return .init(title: download.metadata.title ?? "Untitled", subtitle: download.metadata.subtitle, type: .item(item))
    }

    private func openPlaylist() {
        router.presented = .playlist(medias: downloader.downloads.compactMap(media(from:)))
    }

    private func button(systemImage: String, color: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
        }
        .tint(color)
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
