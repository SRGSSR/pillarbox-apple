//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS 17, *)
struct URNDownloadAction: View {
    let title: String
    let urn: String
    let serverSetting: ServerSetting

    @EnvironmentObject private var downloader: DemoDownloader

    var body: some View {
        Button {
            downloader.addUrnDownload(input: .init(urn: urn, server: serverSetting.server, configuration: .default))
        } label: {
            Image(systemName: "arrow.down")
        }
    }
}
