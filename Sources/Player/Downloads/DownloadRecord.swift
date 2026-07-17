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

    init(input: Input, creationDate: Date) {
        self.init(input: input, metadata: nil, bookmarkData: nil, progress: 0, error: nil, creationDate: creationDate)
    }

    public init(input: Input, metadata: AssetMetadata<CustomData>?, bookmarkData: Data?, progress: Double, error: Error?, creationDate: Date) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.progress = progress
        self.error = error
        self.creationDate = creationDate
    }

    func reset() -> Self {
        .init(input: input, metadata: metadata, bookmarkData: nil, progress: 0, error: nil, creationDate: creationDate)
    }
}

#endif

// swiftlint:enable missing_docs
