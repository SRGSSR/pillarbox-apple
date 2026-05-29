//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let source: DownloadSource
    let fileUrl: URL?
    let error: Error?

    var shouldCreateTask: Bool {
        fileUrl == nil && error == nil
    }

    var state: DownloadState {
        if let error {
            return URLError.isCancellationError(error) ? .cancelled : .completed
        }
        switch source {
        case let .estimate(progress):
            return progress == 1 ? .completed : .preparing
        case let .task(properties):
            switch properties.state {
            case .running:
                return .running
            case .suspended:
                return .suspended
            case .canceling:
                return .cancelled
            case .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
    }

    var progress: Double {
        if error != nil {
            return 0
        }
        switch source {
        case let .estimate(progress):
            return progress
        case let .task(properties):
            return properties.progress
        }
    }

    init() {
        self.init(metadata: nil, source: .estimate(0), fileUrl: nil, error: nil)
    }

    init(metadata: Metadata?, source: DownloadSource, fileUrl: URL?, error: Error?) {
        self.metadata = metadata
        self.source = source
        self.fileUrl = fileUrl
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        do {
            self.fileUrl = try URL(resolvingBookmarkData: record.bookmarkData)
            self.source = .estimate(record.progress)
            self.error = record.error
        } catch {
            self.fileUrl = nil
            self.source = .estimate(0)
            self.error = error
        }
    }

    func bookmarkData() -> Data? {
        try? fileUrl?.bookmarkData()
    }
}

#endif
