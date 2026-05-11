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
    let input: Input
    let metadata: Metadata?
    let bookmarkData: Data?
    let error: Error?

    public init(input: Input, metadata: Metadata?, bookmarkData: Data?, error: Error?) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.error = error
    }

    func url() -> URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    }
}

// swiftlint:enable missing_docs

#endif
