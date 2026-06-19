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
public protocol AssetDownloadStore: AnyObject {
    associatedtype Loader: AssetLoader
    associatedtype CustomData

    static func id(from input: Loader.Input) -> String
    static func customData(from metadata: Loader.Metadata) -> CustomData
    static func asset(fileUrl: URL, input: Loader.Input, customData: CustomData) -> Asset

    func downloadRecords() -> [DownloadRecord<Loader.Input, CustomData>]

    func addDownloadRecord(using input: Loader.Input, forId id: String)
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Loader.Input, CustomData>?
    func updateDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func asset(fileUrl: URL, input: Loader.Input, customData: CustomData) -> Asset {
        .simple(url: fileUrl)
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<CustomData> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

#endif

// swiftlint:enable missing_docs
