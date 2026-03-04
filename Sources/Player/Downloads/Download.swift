//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    private let id = UUID()
    // TODO: Should we keep this public?
    public let title: String
    let task: AVAssetDownloadTask
    let url: URL

    @Published public private(set) var state: AVAssetDownloadTask.State = .running
    @Published public private(set) var progress: Double = 0

    init(title: String, url: URL, session: AVAssetDownloadURLSession) {
        self.title = title
        self.url = url
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        task = session.makeAssetDownloadTask(downloadConfiguration: configuration)

        task.publisher(for: \.state)
            .receiveOnMainThread()
            .assign(to: &$state)

        task.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .assign(to: &$progress)

        task.resume()
    }

    public func resume() {
        task.resume()
        print("--> resume")
    }

    public func suspend() {
        task.suspend()
        print("--> suspend")
    }

}

extension Download: Hashable {
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
