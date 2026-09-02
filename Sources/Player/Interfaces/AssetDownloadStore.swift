//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Combine
import Foundation

@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public protocol AssetDownloadStore: AnyObject {
    associatedtype Loader: AssetLoader
    associatedtype Provider: AssetProvider

    static func id(from input: Loader.Input) -> String

    static func customData(from metadata: Loader.Metadata) -> Provider.CustomData
    static func playerMetadata(from input: Loader.Input, metadata: Loader.Metadata?) -> PlayerMetadata

    func downloadRecords() -> [DownloadRecord<Loader.Input, Provider.CustomData>]

    func addDownloadRecord(_ record: DownloadRecord<Loader.Input, Provider.CustomData>, forId id: String)
    func removeDownloadRecord(forId id: String)

    func downloadRecord(forId id: String) -> DownloadRecord<Loader.Input, Provider.CustomData>?
    func updateDownloadRecord(_ record: DownloadRecord<Loader.Input, Provider.CustomData>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    static func playerMetadata(from input: Loader.Input, metadata: Loader.Metadata?) -> PlayerMetadata {
        Loader.playerMetadata(from: input, metadata: metadata)
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    func downloadProperties(forId id: String) -> DownloadProperties<Provider.CustomData> {
        guard let record = downloadRecord(forId: id) else { return .init() }
        return .init(from: record)
    }
}

@available(tvOS, unavailable)
extension AssetDownloadStore {
    static func assetPublisher(for input: Loader.Input) -> AnyPublisher<DownloadAsset<Provider.CustomData>, any Error> {
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
                    assetMetadata: playerMetadata.withImageSource(imageSource).withCustomData(customData(from: metadata))
                )
            }
            .eraseToAnyPublisher()
    }

    static func taskPublisher(
        id: String,
        input: Loader.Input,
        configuration: DownloadConfiguration,
        reusableAssetMetadata: AssetMetadata<Provider.CustomData>?,
        session: DownloadSession
    ) -> AnyPublisher<DownloadTask<Provider.CustomData>, any Error> {
        if let reusableAssetMetadata {
            return session.taskPublisher(matchingId: id)
                .setFailureType(to: Error.self)
                .map { DownloadTask($0, assetMetadata: reusableAssetMetadata) }
                .eraseToAnyPublisher()
        }
        else {
            return assetPublisher(for: input)
                .map { asset in
                    session.taskPublisher(forId: id, asset: asset.wrappedValue, configuration: configuration, metadata: asset.assetMetadata.playerMetadata)
                        .map { DownloadTask($0, assetMetadata: asset.assetMetadata) }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}

// swiftlint:enable missing_docs
