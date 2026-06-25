//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct DownloadAction: View {
    let media: Media

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addDownload(media: media)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }
}
