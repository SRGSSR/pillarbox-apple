//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

#if DEBUG
struct DownloadsView: View {
    @StateObject private var downloader = Downloader()

    var body: some View {
        List(Array(downloader.downloads), id: \.self) { download in
            cell(for: download)
        }
        .toolbar {
            Menu {
                button(
                    title: "Short video",
                    url: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8"
                )
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private func button(title: String, url: URL) -> some View {
        Button {
            downloader.add(title: title, url: url)
        } label: {
            Text(title)
        }
    }

    private func cell(for download: Download) -> some View {
        VStack(alignment: .leading) {
            Text(download.title)
            if let url = downloader.fileUrl(for: download) {
                Text(url.absoluteString)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DownloadsView()
    }
}
#endif
