//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// swiftlint:disable missing_docs

@_spi(DownloaderPrivate)
import PillarboxPlayer

public final class URNAssetDownloadStore {
    public init() {}
}

@_spi(DownloaderPrivate)
extension URNAssetDownloadStore: AssetDownloadStore {
    public static func id(from input: URNAssetLoader.Input) -> String {
        input.urn
    }

    public func downloadRecords() -> [DownloadRecord<URNAssetLoader.Input, MediaMetadata>] {
        []
    }

    public func addDownloadRecord(using input: URNAssetLoader.Input, forId id: String) {}

    public func removeDownloadRecord(forId id: String) {}

    public func downloadRecord(forId id: String) -> DownloadRecord<URNAssetLoader.Input, MediaMetadata>? {
        nil
    }

    public func updateDownloadRecord(_ record: DownloadRecord<URNAssetLoader.Input, MediaMetadata>, forId id: String) {}
}

// swiftlint:enable missing_docs
