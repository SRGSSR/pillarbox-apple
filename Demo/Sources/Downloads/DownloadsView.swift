//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

#if DEBUG
struct DownloadsView: View {
    @StateObject private var downloader = Downloader()

    var body: some View {
        List(Array(downloader.downloads), id: \.self) { download in
            Text(download.title)
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
}

#Preview {
    NavigationStack {
        DownloadsView()
    }
}
#endif
