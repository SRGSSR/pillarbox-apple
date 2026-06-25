//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Combine
import Foundation

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public protocol AssetDownloadStore: AnyObject {
    associatedtype Loader: AssetLoader
    associatedtype CustomData

    static func id(from input: Loader.Input) -> String
    static func assetPublisher(from input: Loader.Input, metadata: Loader.Metadata) -> AnyPublisher<Asset, Never>
    static func customData(from metadata: Loader.Metadata) -> CustomData
    static func asset(fileUrl: URL, customData: CustomData) -> Asset

    func downloadRecords() -> [DownloadRecord<Loader.Input, CustomData>]

    func addDownloadRecord(using input: Loader.Input, forId id: String)
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Loader.Input, CustomData>?
    func updateDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func asset(fileUrl: URL, customData: CustomData) -> Asset {
        .simple(url: fileUrl)
    }
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func assetPublisher(from input: Loader.Input, metadata: Loader.Metadata) -> AnyPublisher<Asset, Never> {
        Just(Loader.asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<CustomData> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    static func downloadMetadataPublisher(for input: Loader.Input) -> AnyPublisher<DownloadMetadata<Loader.Metadata, CustomData>, any Error> {
        Loader.metadataPublisher(for: input)
            .first()
            .map { metadata in
                let playerMetadata = Loader.playerMetadata(from: input, metadata: metadata)
                return Publishers.CombineLatest3(
                    Just(metadata),
                    Just(playerMetadata),
                    playerMetadata.imageSource.imageSourcePublisher()
                )
            }
            .switchToLatest()
            .map { metadata, playerMetadata, imageSource in
                DownloadMetadata(
                    metadata: metadata,
                    assetMetadata: .init(playerMetadata: playerMetadata.withImageSource(imageSource), customData: customData(from: metadata))
                )
            }
            .eraseToAnyPublisher()
    }
}

#endif

// swiftlint:enable missing_docs
