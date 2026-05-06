//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

// swiftlint:disable missing_docs

@_spi(DownloaderPrivate)
public struct DownloadData<Input, Metadata> {
    let input: Input
    let metadata: Metadata?
    var bookmarkData: Data?

    public init(input: Input, metadata: Metadata?, bookmarkData: Data? = nil) {
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
    }
}

// swiftlint:enable missing_docs

#endif
