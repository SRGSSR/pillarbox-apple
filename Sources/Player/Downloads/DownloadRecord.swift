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
    public let metadata: DownloadMetadata<CustomData>?
    public let bookmarkData: Data?
    public let progress: Double
    public let error: Error?

    public init(input: Input, metadata: DownloadMetadata<CustomData>?, bookmarkData: Data?, progress: Double, error: Error?) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.progress = progress
        self.error = error
    }
}

#endif

// swiftlint:enable missing_docs
