//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum URLAssetLoader<Provider>: AssetLoader where Provider: URLOnlineAssetProvider {
    static func metadataPublisher(for input: URLInput<Provider.CustomData>) -> AnyPublisher<AssetMetadata<Provider.CustomData>, any Error> {
        Just(input.metadata)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    static func asset(from input: URLInput<Provider.CustomData>, metadata: AssetMetadata<Provider.CustomData>) -> Asset {
        Provider.asset(from: input, metadata: metadata)
    }

    static func downloadableAssetPublisher(from input: URLInput<Provider.CustomData>, metadata: AssetMetadata<Provider.CustomData>) -> AnyPublisher<Asset, Never> {
        Provider.downloadableAssetPublisher(from: input, metadata: metadata)
    }

    static func playerMetadata(from input: URLInput<Provider.CustomData>, metadata: AssetMetadata<Provider.CustomData>?) -> PlayerMetadata {
        input.metadata.playerMetadata
    }
}
