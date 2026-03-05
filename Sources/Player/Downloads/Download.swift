//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class Download: ObservableObject {
    let url: URL
    @Published private(set) var state: AVAssetDownloadTask.State = .running

    init(url: URL, session: AVAssetDownloadURLSession) {
        self.url = url
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: "Unknown")
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)

        task.publisher(for: \.state)
            .assign(to: &$state)
        task.resume()
    }
}

extension Download: Hashable {
    static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
