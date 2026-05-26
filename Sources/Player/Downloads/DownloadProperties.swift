//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let source: DownloadSource
    let location: URL?
    let error: Error?

    var shouldCreateTask: Bool {
        location == nil && error == nil
    }

    var state: DownloadState {
        if let error {
            return URLError.isCancellationError(error) ? .cancelled : .completed
        }
        switch source {
        case let .estimate(progress):
            // TODO: Check conditions here with UTs
            if location != nil {
                return .completed
            }
            else {
                return progress > 0 ? .completed : .preparing
            }
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
            return location != nil ? progress : 0
        case let .task(properties):
            return properties.progress
        }
    }

    init() {
        self.init(metadata: nil, source: .estimate(0), location: nil, error: nil)
    }

    init(metadata: Metadata?, source: DownloadSource, location: URL?, error: Error?) {
        self.metadata = metadata
        self.source = source
        self.location = location
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        do {
            self.location = try Self.url(resolvingBookmarkData: record.bookmarkData)
            self.source = .estimate(record.progress)
            self.error = record.error
        }
        catch {
            self.location = nil
            self.source = .estimate(0)
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
