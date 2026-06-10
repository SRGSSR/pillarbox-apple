//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import SwiftUI

struct URLDownloadAction: View {
    let title: String
    let url: URL

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrlDownload(title: title, url: url)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }
}

#endif
