//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    private let id = UUID()

    public var title: String? {
        nil
    }

    @Published public private(set) var state: AVAssetDownloadTask.State = .running
    @Published public private(set) var progress: Double = 0

    init(task: URLSessionTask) {

    }

    public func resume() {

    }

    public func suspend() {

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
