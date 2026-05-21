//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let job: DownloadJob
    let location: URL?
    let error: Error?

    var shouldCreateJob: Bool {
        location == nil && error == nil
    }

    var state: DownloadState {
        if let error {
            return .failed(error)
        }
        switch job {
        case let .none(estimatedProgress: progress):
            if location != nil {
                return progress == 1 ? .completed : .failed(CocoaError(.fileNoSuchFile))
            }
            else {
                return progress > 0 ? .failed(CocoaError(.fileNoSuchFile)) : .preparing
            }
        case let .task(task):
            switch task.state {
            case .running, .canceling:
                return .running
            case .suspended:
                return .suspended
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
        switch job {
        case let .none(estimatedProgress: progress):
            return location != nil ? progress : 0
        case let .task(task):
            return task.progress
        }
    }

    init() {
        self.init(metadata: nil, job: .none(estimatedProgress: 0), location: nil, error: nil)
    }

    init(metadata: Metadata?, job: DownloadJob, location: URL?, error: Error?) {
        self.metadata = metadata
        self.job = job
        self.location = location
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        do {
            self.location = try Self.url(resolvingBookmarkData: record.bookmarkData)
            self.job = .none(estimatedProgress: record.progress)
            self.error = record.error
        }
        catch {
            self.location = nil
            self.job = .none(estimatedProgress: 0)
            self.error = error
        }
    }

    private static func url(resolvingBookmarkData bookmarkData: Data?) throws -> URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        return try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    }

    func bookmarkData() -> Data? {
        try? location?.bookmarkData()
    }
}

#endif
