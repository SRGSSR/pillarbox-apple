//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DOWNLOADS

import SwiftUI

struct DownloadAction: View {
    let media: Media

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        if downloader.canDownload {
            Button {
                downloader.addDownload(media: media)
            } label: {
                Image(systemName: "arrow.down.circle")
            }
            .tint(.green)
        }
    }
}

#endif
