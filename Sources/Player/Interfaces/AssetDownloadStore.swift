//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

/// A protocol defining how downloads are loaded and persisted.
@_spi(DownloaderPrivate)
@available(tvOS, unavailable)
public protocol AssetDownloadStore: AnyObject {
    /// The type of loader used to load the underlying asset.
    associatedtype Loader: AssetLoader

    /// A custom type that describes data to persist with each download.
    ///
    /// Persisted data can be reused when creating trackers for local player items returned by ``Downloader/playerItem(for:trackerAdapters:)``.
    /// Any data required to create a local ``Asset`` should also be persisted.
    associatedtype CustomData

    /// Creates a unique identifier for the given download input.
    ///
    /// - Parameter input: The input that identifies the download.
    /// - Returns: A string that uniquely identifies the download.
    static func id(from input: Loader.Input) -> String

    /// Extracts a custom subset of metadata from the asset loader metadata.
    ///
    /// - Parameter metadata: The original metadata provided by the asset loader.
    /// - Returns: The metadata subset to persist with the download.
    static func customData(from metadata: Loader.Metadata) -> CustomData

    /// Creates an asset from a local file URL and custom data.
    ///
    /// - Parameters:
    ///   - fileUrl: The URL of the file to be played.
    ///   - customData: Custom data associated with the download.
    /// - Returns: A playable local asset. Implementations that create custom or encrypted assets should persist any
    ///   information needed to distinguish or reconstruct the asset in `CustomData`.
    static func asset(fileUrl: URL, customData: CustomData) -> Asset

    /// Converts input and metadata into player metadata.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: Player metadata describing the asset.
    ///
    /// If this method is not implemented, the ``AssetLoader/playerMetadata(from:metadata:)`` implementation is used
    /// instead. Implement this method only when the metadata displayed for a download needs to differ from the metadata
    /// provided by the original asset loader.
    static func playerMetadata(from input: Loader.Input, metadata: Loader.Metadata?) -> PlayerMetadata

    /// Returns all available download records.
    func downloadRecords() -> [DownloadRecord<Loader.Input, CustomData>]

    /// Adds a download record to the store.
    ///
    /// - Parameters:
    ///   - record: The record to add.
    ///   - id: The unique identifier for the record.
    func addDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)

    /// Removes a download record from the store.
    ///
    /// - Parameter id: The unique identifier of the record.
    func removeDownloadRecord(forId id: String)

    /// Returns the download record matching the given identifier.
    ///
    /// - Parameter id: The unique identifier of the record.
    /// - Returns: The matching record, if one exists.
    func downloadRecord(forId id: String) -> DownloadRecord<Loader.Input, CustomData>?

    /// Updates a download record.
    ///
    /// - Parameters:
    ///   - record: The updated record.
    ///   - id: The unique identifier of the record.
    func updateDownloadRecord(_ record: DownloadRecord<Loader.Input, CustomData>, forId id: String)
}

@available(tvOS, unavailable)
public extension AssetDownloadStore {
    /// Default implementation. Returns a simple asset.
    static func asset(fileUrl: URL, customData: CustomData) -> Asset {
        .simple(url: fileUrl)
    }

    /// Default implementation. Returns player metadata defined by the associated ``AssetLoader``.
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
        configuration: DownloadConfiguration,
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
                    session.taskPublisher(forId: id, asset: asset.wrappedValue, configuration: configuration, metadata: asset.assetMetadata.playerMetadata)
                        .map { DownloadTask($0, assetMetadata: asset.assetMetadata) }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}

#endif
