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
    let isMonoscopic: Bool

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrlDownload(title: title, url: url, isMonoscopic: isMonoscopic)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }

    init(title: String, url: URL, isMonoscopic: Bool = false) {
        self.title = title
        self.url = url
        self.isMonoscopic = isMonoscopic
    }
}

#endif
