//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import OSLog

enum AssetType {
    case simple(url: URL)
    case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
    case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

    private static let logger = Logger(category: "Asset")

    func playerItem() -> AVPlayerItem {
        switch self {
        case let .simple(url: url):
            return AVPlayerItem(url: url)
        case let .custom(url: url, delegate: delegate):
            return ResourceLoadedPlayerItem(
                url: url,
                resourceLoaderDelegate: delegate
            )
        case let .encrypted(url: url, delegate: delegate):
#if targetEnvironment(simulator)
            Self.logger.error("FairPlay-encrypted assets cannot be played in the simulator")
            return AVPlayerItem(url: url)
#else
            let asset = AVURLAsset(url: url)
            kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
            kContentKeySession.addContentKeyRecipient(asset)
            kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
            return AVPlayerItem(asset: asset)
#endif
        }
    }
}

extension AssetType: Equatable {
    static func == (lhs: AssetType, rhs: AssetType) -> Bool {
        switch (lhs, rhs) {
        case let (.simple(url: lhsUrl), .simple(url: rhsUrl)):
            return lhsUrl == rhsUrl
        case let (.custom(url: lhsUrl, delegate: lhsDelegate), .custom(url: rhsUrl, delegate: rhsDelegate)):
            return lhsUrl == rhsUrl && lhsDelegate === rhsDelegate
        case let (.encrypted(url: lhsUrl, delegate: lhsDelegate), .encrypted(url: rhsUrl, delegate: rhsDelegate)):
            return lhsUrl == rhsUrl && lhsDelegate === rhsDelegate
        default:
            return false
        }
    }
}
