//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var downloaders: Downloaders
    @EnvironmentObject private var router: Router

    var body: some View {
        ZStack {
            if !downloaders.downloads.isEmpty {
                mainView()
            }
            else {
                emptyView()
            }
        }
        .animation(.defaultLinear, value: downloaders.downloads)
        .toolbar {
            removeAllButton()
        }
        .navigationTitle("Downloads")
    }

    private func mainView() -> some View {
        List {
            ForEach(downloaders.downloads, id: \.self) { download in
                DownloadCell(download: download) {
                    if let item = downloaders.playerItem(for: download) {
                        router.presented = .player(media: .init(title: download.metadata.title ?? "Untitled", type: .item(item)))
                    }
                }
            }
            .onDelete { indexes in
                for index in indexes.reversed() {
                    downloaders.removeDownload(downloaders.downloads[index])
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
        Button {
            downloaders.removeAllDownloads()
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
