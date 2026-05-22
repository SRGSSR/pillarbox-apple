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
    private let _error: Error?

    var shouldCreateTask: Bool {
        location == nil && error == nil
    }

    var state: DownloadState {
        if _error != nil {
            return .completed
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
                return .completed
            case .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
    }

    var error: Error? {
        if let _error {
            return _error
        }
        switch source {
        case let .estimate(progress):
            // TODO: Check conditions here with UTs
            if location != nil {
                return progress == 1 ? nil : CocoaError(.fileNoSuchFile)
            }
            else {
                return progress > 0 ? CocoaError(.fileNoSuchFile) : nil
            }
        default:
            return nil
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
        self._error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        do {
            self.location = try Self.url(resolvingBookmarkData: record.bookmarkData)
            self.source = .estimate(record.progress)
            self._error = record.error
        }
        catch {
            self.location = nil
            self.source = .estimate(0)
            self._error = error
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
