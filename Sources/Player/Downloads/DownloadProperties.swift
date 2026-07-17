//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadProperties<CustomData> {
    let progress: DownloadProgress
    let assetMetadata: AssetMetadata<CustomData>?
    let fileUrl: URL?
    let error: Error?

    var reusableAssetMetadata: AssetMetadata<CustomData>? {
        fileUrl != nil || error != nil ? assetMetadata : nil
    }

    var state: DownloadState {
        if error != nil {
            return .completed
        }
        switch progress {
        case let .estimate(progress):
            return progress == 1 ? .completed : .preparing
        case let .actual(properties):
            switch properties.state {
            case .running:
                return .running
            case .suspended:
                return .suspended
            case .canceling, .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
    }

    var fractionCompleted: Double {
        if error != nil {
            return 0
        }
        switch progress {
        case let .estimate(progress):
            return progress
        case let .actual(properties):
            return properties.progress
        }
    }

    private var task: URLSessionTask? {
        switch progress {
        case .estimate:
            return nil
        case let .actual(properties):
            return properties.task
        }
    }

    init() {
        self.init(progress: .estimate(0), assetMetadata: nil, fileUrl: nil, error: nil)
    }

    init(progress: DownloadProgress, assetMetadata: AssetMetadata<CustomData>?, fileUrl: URL?, error: Error?) {
        self.progress = progress
        self.assetMetadata = assetMetadata
        self.fileUrl = fileUrl
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, CustomData>) {
        do {
            self.init(
                progress: .estimate(record.progress),
                assetMetadata: record.metadata,
                fileUrl: try URL(resolvingBookmarkData: record.bookmarkData),
                error: record.error
            )
        } catch {
            self.init(
                progress: .estimate(0),
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

    func withError(_ error: Error) -> Self {
        .init(progress: progress, assetMetadata: assetMetadata, fileUrl: fileUrl, error: error)
    }
}

#endif
