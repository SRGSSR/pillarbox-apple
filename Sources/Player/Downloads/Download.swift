//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    let id: String

    public let title: String

    @Published public private(set) var state: URLSessionTask.State
    @Published public private(set) var progress: Double

    private let task: URLSessionTask?

    init(id: String = UUID().uuidString, title: String, task: URLSessionTask? = nil) {
        self.id = id
        self.title = title
        self.task = task

        if let task {
            self.state = .running
            self.progress = 0

            task.taskDescription = id

            task.publisher(for: \.state)
                .receiveOnMainThread()
                .assign(to: &$state)
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
                .receiveOnMainThread()
                .assign(to: &$progress)
        }
        else {
            self.state = .completed
            self.progress = 1
        }
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
