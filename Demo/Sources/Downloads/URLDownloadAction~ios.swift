//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import SwiftUI

struct URLDownloadAction: View {
    let url: URL
    let title: String
    let subtitle: String?
    let isMonoscopic: Bool

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrlDownload(title: title, subtitle: subtitle, url: url, isMonoscopic: isMonoscopic)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }

    init(url: URL, title: String, subtitle: String? = nil, isMonoscopic: Bool = false) {
        self.url = url
        self.title = title
        self.subtitle = subtitle
        self.isMonoscopic = isMonoscopic
    }
}

#endif
