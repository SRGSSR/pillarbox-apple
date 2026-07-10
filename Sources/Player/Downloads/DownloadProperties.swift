//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadProperties<CustomData> {
    let downloadProgress: DownloadProgress
    let assetMetadata: AssetMetadata<CustomData>?
    let fileUrl: URL?
    let error: Error?

    var reusableAssetMetadata: AssetMetadata<CustomData>? {
        fileUrl != nil || error != nil ? assetMetadata : nil
    }

    var state: DownloadState {
        if let error {
            return URLError.isCancellationError(error) ? .cancelled : .completed
        }
        switch downloadProgress {
        case let .estimate(progress):
            return progress == 1 ? .completed : .preparing
        case let .actual(properties):
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
        switch downloadProgress {
        case let .estimate(progress):
            return progress
        case let .actual(properties):
            return properties.progress
        }
    }

    private var task: URLSessionTask? {
        switch downloadProgress {
        case .estimate:
            return nil
        case let .actual(properties):
            return properties.task
        }
    }

    init() {
        self.init(
            downloadProgress: .estimate(0),
            assetMetadata: nil,
            fileUrl: nil,
            error: nil
        )
    }

    init(downloadProgress: DownloadProgress, assetMetadata: AssetMetadata<CustomData>?, fileUrl: URL?, error: Error?) {
        self.downloadProgress = downloadProgress
        self.assetMetadata = assetMetadata
        self.fileUrl = fileUrl
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, CustomData>) {
        do {
            self.init(
                downloadProgress: .estimate(record.progress),
                assetMetadata: record.metadata,
                fileUrl: try URL(resolvingBookmarkData: record.bookmarkData),
                error: record.error
            )
        } catch {
            self.init(
                downloadProgress: .estimate(0),
                assetMetadata: record.metadata,
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
