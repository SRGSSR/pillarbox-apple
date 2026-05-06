//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

// swiftlint:disable missing_docs

@_spi(DownloaderPrivate)
public struct DownloadData<Input, Metadata> {
    let input: Input
    let metadata: Metadata
}

// swiftlint:enable missing_docs

#endif
