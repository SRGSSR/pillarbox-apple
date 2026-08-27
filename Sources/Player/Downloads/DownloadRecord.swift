//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

/// Contains data associated with a download record.
///
/// ``AssetDownloadStore`` implementations must persist all data associated with a record.
@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public struct DownloadRecord<Input, CustomData> {
    /// The input used to perform the download.
    public let input: Input

    /// The download's configuration.
    public let configuration: DownloadConfiguration

    /// The asset metadata associated with the download.
    public let metadata: AssetMetadata<CustomData>?

    /// Bookmark data identifying the downloaded file on disk, if available.
    public let bookmarkData: Data?

    /// Information about the download's progress.
    public let progress: Double

    /// Error information associated with the download, if any.
    public let error: Error?

    /// The date when the download was created.
    public let creationDate: Date

    init(input: Input, configuration: DownloadConfiguration, creationDate: Date) {
        self.init(input: input, configuration: configuration, metadata: nil, bookmarkData: nil, progress: 0, error: nil, creationDate: creationDate)
    }

    /// Creates a download record.
    ///
    /// - Parameters:
    ///   - input: The input used to perform the download.
    ///   - configuration: The download's configuration.
    ///   - metadata: The asset metadata associated with the download.
    ///   - bookmarkData: Bookmark data identifying the downloaded file on disk, if available.
    ///   - progress: Information about the download's progress.
    ///   - error: Error information associated with the download, if any.
    ///   - creationDate: The date when the download was created.
    public init(
        input: Input,
        configuration: DownloadConfiguration,
        metadata: AssetMetadata<CustomData>?,
        bookmarkData: Data?,
        progress: Double,
        error: Error?,
        creationDate: Date
    ) {
        self.input = input
        self.configuration = configuration
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.progress = progress
        self.error = error
        self.creationDate = creationDate
    }

    func reset(configuration: DownloadConfiguration) -> Self {
        .init(input: input, configuration: configuration, metadata: metadata, bookmarkData: nil, progress: 0, error: nil, creationDate: creationDate)
    }
}

#endif
