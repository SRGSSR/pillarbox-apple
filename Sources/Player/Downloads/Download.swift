//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    public let title: String

    let taskDescription: String

    public private(set) var state: AVAssetDownloadTask.State = .running
    public private(set) var progress: Double = 0

    init(title: String, taskDescription: String = UUID().uuidString) {
        self.title = title
        self.taskDescription = taskDescription
    }

    public func resume() {

    }

    public func suspend() {

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
