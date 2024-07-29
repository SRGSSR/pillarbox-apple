//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import os

private let kContentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
private let kContentKeySessionQueue = DispatchQueue(label: "ch.srgssr.player.content_key_session")

enum Resource {
    case simple(url: URL)
    case custom(url: URL, delegate: AVAssetResourceLoaderDelegate)
    case encrypted(url: URL, delegate: AVContentKeySessionDelegate)

    private static let logger = Logger(category: "Resource")

    var isFailing: Bool {
        switch self {
        case let .custom(url: url, _) where url == Self.failingUrl:
            true
        default:
            false
        }
    }

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

extension Resource {
    // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
    static let loadingUrl = URL(string: "pillarbox://loading.m3u8")!
    static let failingUrl = URL(string: "pillarbox://failing.m3u8")!

    static let loading = Self.custom(url: loadingUrl, delegate: LoadingResourceLoaderDelegate())

    static func failing(error: Error) -> Self {
        .custom(url: failingUrl, delegate: FailedResourceLoaderDelegate(error: error))
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
