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

    static func customData(from metadata: Loader.Metadata) -> CustomData
    static func asset(fileUrl: URL, customData: CustomData) -> Asset
    static func playerMetadata(from input: Loader.Input, metadata: Loader.Metadata?) -> PlayerMetadata

    func downloadRecords() -> [DownloadRecord<Loader.Input, CustomData>]

    func addDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Loader.Input, CustomData>?
    func updateDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func asset(fileUrl: URL, customData: CustomData) -> Asset {
        .simple(url: fileUrl)
    }

    static func playerMetadata(from input: Loader.Input, metadata: Loader.Metadata?) -> PlayerMetadata {
        Loader.playerMetadata(from: input, metadata: metadata)
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
    static func assetPublisher(for input: Loader.Input) -> AnyPublisher<DownloadAsset<CustomData>, any Error> {
        Loader.metadataPublisher(for: input)
            .first()
            .map { metadata in
                let playerMetadata = playerMetadata(from: input, metadata: metadata)
                return Publishers.CombineLatest3(
                    Just(metadata),
                    Just(playerMetadata),
                    playerMetadata.imageSource.imageSourcePublisher()
                )
            }
            .switchToLatest()
            .map { metadata, playerMetadata, imageSource in
                DownloadAsset(
                    Loader.asset(from: input, metadata: metadata),
                    assetMetadata: .init(playerMetadata: playerMetadata.withImageSource(imageSource), customData: customData(from: metadata))
                )
            }
            .eraseToAnyPublisher()
    }

    static func taskPublisher(
        id: String,
        input: Loader.Input,
        reusableAssetMetadata: AssetMetadata<CustomData>?,
        session: DownloadSession
    ) -> AnyPublisher<DownloadTask<CustomData>, any Error> {
        if let reusableAssetMetadata {
            return session.taskPublisher(matchingId: id)
                .setFailureType(to: Error.self)
                .map { DownloadTask($0, assetMetadata: reusableAssetMetadata) }
                .eraseToAnyPublisher()
        }
        else {
            return assetPublisher(for: input)
                .map { asset in
                    session.taskPublisher(forId: id, asset: asset.wrappedValue, metadata: asset.assetMetadata.playerMetadata)
                        .map { DownloadTask($0, assetMetadata: asset.assetMetadata) }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}

#endif

// swiftlint:enable missing_docs
