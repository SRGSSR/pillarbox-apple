//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    private let id = UUID()
    let task: URLSessionTask

    public var title: String? {
        task.taskDescription
    }

    @Published public private(set) var state: AVAssetDownloadTask.State = .running
    @Published public private(set) var progress: Double = 0

    init(task: URLSessionTask) {
        self.task = task

        task.publisher(for: \.state)
            .receiveOnMainThread()
            .assign(to: &$state)

        task.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .assign(to: &$progress)
    }

    public func resume() {
        task.resume()
    }

    public func suspend() {
        task.suspend()
    }

    func cancel() {
        task.cancel()
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
