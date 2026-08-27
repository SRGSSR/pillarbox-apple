//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@available(tvOS, unavailable)
struct DownloadProperties<CustomData> {
    let configuration: DownloadConfiguration
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
            return properties.fractionCompleted
        }
    }

    var size: DownloadSize? {
        if let size = Self.downloadSize(from: progress), error == nil {
            return size
        }
        else if let fileUrl {
            return .init(url: fileUrl)
        }
        else {
            return nil
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
        self.init(configuration: .default, progress: .estimate(0), assetMetadata: nil, fileUrl: nil, error: nil)
    }

    init(configuration: DownloadConfiguration, progress: DownloadProgress, assetMetadata: AssetMetadata<CustomData>?, fileUrl: URL?, error: Error?) {
        self.configuration = configuration
        self.progress = progress
        self.assetMetadata = assetMetadata
        self.fileUrl = fileUrl
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, CustomData>) {
        do {
            self.init(
                configuration: record.configuration,
                progress: .estimate(record.progress),
                assetMetadata: record.metadata,
                fileUrl: try URL(resolvingBookmarkData: record.bookmarkData),
                error: record.error
            )
        } catch {
            self.init(
                configuration: record.configuration,
                progress: .estimate(0),
                assetMetadata: record.metadata,
                fileUrl: nil,
                error: error
            )
        }
    }

    private static func downloadSize(from progress: DownloadProgress) -> DownloadSize? {
        switch progress {
        case .estimate:
            return nil
        case let .actual(properties):
            return properties.size
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
        .init(configuration: configuration, progress: progress, assetMetadata: assetMetadata, fileUrl: nil, error: error)
    }
}

#endif
