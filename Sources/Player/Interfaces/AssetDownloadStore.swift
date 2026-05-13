//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
public protocol AssetDownloadStore: AnyObject {
    associatedtype Input
    associatedtype Metadata

    static func identifier(for input: Input) -> String

    func downloadRecord(for identifier: String) -> DownloadRecord<Input, Metadata>?
    func downloadRecords() -> [DownloadRecord<Input, Metadata>]

    func addDownloadRecord(using input: Input, for identifier: String)
    func removeDownloadRecord(for identifier: String)

    func updateDownloadRecord(_ record: DownloadRecord<Input, Metadata>, for identifier: String)
}

#endif

// swiftlint:enable missing_docs
