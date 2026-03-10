//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    let id: String

    public let title: String
    public let remoteUrl: URL

    @Published public private(set) var state: URLSessionTask.State = .completed
    @Published public private(set) var progress: Double = 1

    private let task: URLSessionTask?

    init(metadata: DownloadMetadata, task: URLSessionTask?) {
        self.id = metadata.id
        self.title = metadata.title
        self.remoteUrl = metadata.remoteUrl
        self.task = task

        configureTaskPublisher()
    }

    init(title: String, task: URLSessionTask) {
        self.id = task.taskDescription!
        self.title = title
        self.remoteUrl = task.currentRequest!.url!
        self.task = task

        configureTaskPublisher()
    }

    private func configureTaskPublisher() {
        task?.publisher(for: \.state)
            .receiveOnMainThread()
            .assign(to: &$state)

        task?.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .assign(to: &$progress)
    }

    public func resume() {
        task?.resume()
    }

    public func suspend() {
        task?.suspend()
    }

    func cancel() {
        task?.cancel()
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
