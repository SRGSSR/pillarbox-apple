//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    public let title: String

    let taskDescription: String

    @Published public private(set) var state: URLSessionTask.State
    @Published public private(set) var progress: Double

    private let task: URLSessionTask?

    init(title: String, taskDescription: String, task: URLSessionTask? = nil) {
        self.title = title
        self.taskDescription = taskDescription
        self.task = task

        if let task {
            self.state = .running
            self.progress = 0

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
}

extension Download: Hashable {
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.taskDescription == rhs.taskDescription
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(taskDescription)
    }
}
