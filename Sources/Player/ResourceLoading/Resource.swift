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

    private func asset(for url: URL, with configuration: PlayerConfiguration) -> AVURLAsset {
        .init(url: url, options: [
            AVURLAssetAllowsConstrainedNetworkAccessKey: configuration.allowsConstrainedNetworkAccess
        ])
    }

    func playerItem(configuration: PlayerConfiguration) -> AVPlayerItem {
        switch self {
        case let .simple(url: url):
            return AVPlayerItem(asset: asset(for: url, with: configuration))
        case let .custom(url: url, delegate: delegate):
            return ResourceLoadedPlayerItem(
                asset: asset(for: url, with: configuration),
                resourceLoaderDelegate: delegate
            )
        case let .encrypted(url: url, delegate: delegate):
#if targetEnvironment(simulator)
            Self.logger.error("FairPlay-encrypted assets cannot be played in the simulator")
            return AVPlayerItem(asset: asset(for: url, with: configuration))
#else
            let asset = asset(for: url, with: configuration)
            kContentKeySession.setDelegate(delegate, queue: kContentKeySessionQueue)
            kContentKeySession.addContentKeyRecipient(asset)
            kContentKeySession.processContentKeyRequest(withIdentifier: nil, initializationData: nil)
            return AVPlayerItem(asset: asset)
#endif
        }
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
    static let loading = Self.custom(url: .loading, delegate: LoadingResourceLoaderDelegate())

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
