//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadProperties<CustomData> {
    let source: DownloadSource
    let metadata: AssetMetadata<CustomData>?
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

    private var task: URLSessionTask? {
        switch source {
        case .estimate:
            return nil
        case let .task(properties):
            return properties.task
        }
    }

    init() {
        self.init(
            source: .estimate(0),
            metadata: nil,
            fileUrl: nil,
            error: nil
        )
    }

    init(source: DownloadSource, metadata: AssetMetadata<CustomData>?, fileUrl: URL?, error: Error?) {
        self.source = source
        self.metadata = metadata
        self.fileUrl = fileUrl
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, CustomData>) {
        do {
            self.init(
                source: .estimate(record.progress),
                metadata: record.metadata,
                fileUrl: try URL(resolvingBookmarkData: record.bookmarkData),
                error: record.error
            )
        } catch {
            self.init(
                source: .estimate(0),
                metadata: record.metadata,
                fileUrl: nil,
                error: error
            )
        }
    }

    func bookmarkData() -> Data? {
        try? fileUrl?.bookmarkData()
    }

    func resume() {
        task?.resume()
    }

    func suspend() {
        task?.suspend()
    }

    func cancel() {
        task?.cancel()
    }
}

#endif
