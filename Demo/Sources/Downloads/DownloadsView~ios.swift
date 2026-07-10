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
        .animation(.defaultLinear, value: downloader.downloads)
        .toolbar {
            removeAllButton()
        }
        .navigationTitle("Downloads")
    }

    private func mainView() -> some View {
        List {
            ForEach(downloader.downloads, id: \.self) { download in
                DownloadCell(download: download) {
                    if let item = downloader.playerItem(for: download) {
                        router.presented = .player(media: .init(title: download.metadata.title ?? "Untitled", type: .item(item)))
                    }
                }
                .swipeActions {
                    button(systemImage: "arrow.counterclockwise", action: download.restart)
                    button(systemImage: "trash") { downloader.removeDownload(download) }
                }
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
        }
    }

    private func button(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
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
