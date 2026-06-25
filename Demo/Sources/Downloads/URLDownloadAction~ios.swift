//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import PillarboxPlayer
import SwiftUI

struct URLDownloadAction: View {
    let url: URL
    let metadata: PlayerMetadata

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrlDownload(url: url, metadata: metadata)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }

    init(url: URL, metadata: PlayerMetadata = .empty) {
        self.url = url
        self.metadata = metadata
    }
}

#endif
