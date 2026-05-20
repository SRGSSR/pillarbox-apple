//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

// swiftlint:disable missing_docs

@_spi(DownloaderPrivate)
public struct DownloadRecord<Input, Metadata> {
    public let input: Input
    public let metadata: Metadata?
    public let bookmarkData: Data?
    public let progress: Double
    public let error: Error?

    public init(input: Input, metadata: Metadata?, bookmarkData: Data?, progress: Double, error: Error?) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.progress = progress
        self.error = error
    }

    func reset() -> Self {
        .init(input: input, metadata: nil, bookmarkData: nil, progress: 0, error: nil)
    }
}

// swiftlint:enable missing_docs

#endif
