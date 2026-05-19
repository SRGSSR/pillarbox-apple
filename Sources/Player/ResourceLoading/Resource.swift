//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import os

private let kContentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
private let kContentKeySessionQueue = DispatchQueue(label: "ch.srgssr.player.content-key-session")

enum Resource {
    case simple(url: URL)
    case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
    case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

    private static let logger = Logger(category: "Resource")

    var error: Error? {
        switch self {
        case let .custom(_, delegate: delegate):
            guard let failedDelegate = delegate as? FailedResourceLoaderDelegate else { return nil }
            return failedDelegate.error
        default:
            return nil
        }
    }

    private func asset(for url: URL, with configuration: PlayerConfiguration) -> AVURLAsset {
        .init(url: url, options: [
            AVURLAssetAllowsConstrainedNetworkAccessKey: configuration.allowsConstrainedNetworkAccess
        ])
    }

    func urlAsset(configuration: PlayerConfiguration) -> AVURLAsset {
        switch self {
        case let .simple(url: url):
            return asset(for: url, with: configuration)
        case let .custom(url: url, delegate: delegate):
            let asset = asset(for: url, with: configuration)
            // FIXME:
            // asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: kResourceLoaderQueue)
            return asset
        case let .encrypted(url: url, delegate: delegate):
#if targetEnvironment(simulator)
            Self.logger.error("FairPlay-encrypted assets cannot be played in the simulator")
            return asset(for: url, with: configuration)
#else
            let asset = asset(for: url, with: configuration)
            kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
            kContentKeySession.addContentKeyRecipient(asset)
            return asset
#endif
        }
    }

    func playerItem(configuration: PlayerConfiguration) -> AVPlayerItem {
        .init(asset: urlAsset(configuration: configuration), automaticallyLoadedAssetKeys: ["duration"])
    }
}

extension Resource: PlaybackResource {
    func contains(url: URL) -> Bool {
        switch self {
        case let .custom(url: customUrl, _) where customUrl == url:
            true
        default:
            false
        }
    }
}

extension Resource {
    static func loading() -> Self {
        .custom(url: .loading, delegate: LoadingResourceLoaderDelegate())
    }

    static func failing(error: Error) -> Self {
        .custom(url: .failing, delegate: FailedResourceLoaderDelegate(error: error))
    }
}

extension Resource: Equatable {
    static func == (lhs: Resource, rhs: Resource) -> Bool {
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
