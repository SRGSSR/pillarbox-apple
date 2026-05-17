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
    public let id: String
    public let input: Input
    public let metadata: Metadata?
    public let bookmarkData: Data?
    public let error: Error?

    public init(id: String, input: Input, metadata: Metadata?, bookmarkData: Data?, error: Error?) {
        self.id = id
        self.input = input
        self.metadata = metadata
        self.bookmarkData = bookmarkData
        self.error = error
    }

    init(input: Input, metadata: Metadata?, bookmarkData: Data?, error: Error?) {
        self.init(id: UUID().uuidString, input: input, metadata: metadata, bookmarkData: bookmarkData, error: error)
    }

    func reset() -> Self {
        .init(id: id, input: input, metadata: nil, bookmarkData: nil, error: nil)
    }
}

// swiftlint:enable missing_docs

#endif
