//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public struct DownloadRecord<Input, CustomData> {
    public let input: Input
    public let metadata: AssetMetadata<CustomData>?
    public let bookmarkData: Data?
    public let progress: Double
    public let error: Error?
    public let creationDate: Date

    public init(
        input: Input,
        metadata: AssetMetadata<CustomData>? = nil,
        bookmarkData: Data? = nil,
        progress: Double = 0,
        error: Error? = nil,
        creationDate: Date = .now
    ) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.progress = progress
        self.error = error
        self.creationDate = creationDate
    }
}

#endif

// swiftlint:enable missing_docs
