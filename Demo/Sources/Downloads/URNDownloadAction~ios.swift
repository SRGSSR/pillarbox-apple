//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import SwiftUI

@available(iOS 17, *)
struct URNDownloadAction: View {
    let urn: String
    let serverSetting: ServerSetting

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrnDownload(urn: urn, serverSetting: serverSetting)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .tint(.green)
    }
}

#endif
