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

    var reusableAssetMetadata: AssetMetadata<CustomData>? {
        fileUrl != nil || error != nil ? assetMetadata : nil
    }

    var state: DownloadState {
        if error != nil {
            return .completed
        }
        switch progress {
        case let .estimate(progress, _, _):
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

    var fileUrl: URL? {
        progress.location
    }

    var error: Error? {
        progress.error
    }

    var fractionCompleted: Double {
        if error != nil {
            return 0
        }
        return progress.fractionCompleted
    }

    private var task: URLSessionTask? {
        progress.task
    }

    init() {
        self.init(progress: .estimate(0, location: nil, error: nil), assetMetadata: nil)
    }

    init(progress: DownloadProgress, assetMetadata: AssetMetadata<CustomData>?) {
        self.progress = progress
        self.assetMetadata = assetMetadata
    }

    init<Input>(from record: DownloadRecord<Input, CustomData>) {
        do {
            self.init(
                progress: .estimate(record.progress, location: try URL(resolvingBookmarkData: record.bookmarkData), error: record.error),
                assetMetadata: record.metadata
            )
        } catch {
            self.init(
                progress: .estimate(0, location: nil, error: error),
                assetMetadata: record.metadata
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
