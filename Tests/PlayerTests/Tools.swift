//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct Stream {
    let url: URL
    let duration: CMTime
}

enum TestError: Error {
    case any
}

enum TestStreams {
    static let onDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
        duration: CMTime(value: 120, timescale: 1)
    )
    static let shortOnDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!,
        duration: CMTime(value: 1, timescale: 1)
    )
    static let corruptOnDemand = Stream(
        url: URL(string: "http://localhost:8123/on_demand_corrupt/master.m3u8")!,
        duration: CMTime(value: 2, timescale: 1)
    )

    static let live = Stream(
        url: URL(string: "http://localhost:8123/live/master.m3u8")!,
        duration: .zero
    )
    static let dvr = Stream(
        url: URL(string: "http://localhost:8123/dvr/master.m3u8")!,
        duration: CMTime(value: 20, timescale: 1)
    )

    static let unavailable = Stream(
        url: URL(string: "http://localhost:8123/unavailable/master.m3u8")!,
        duration: .indefinite
    )
    static let custom = Stream(
        url: URL(string: "custom://arbitrary.server/some.m3u8")!,
        duration: .indefinite
    )
}

final class FailingResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate {
    // Correct error propagation from the resource loader to the player item requires the following:
    //   - The error code must be an `Int`.
    //   - The error code must be different from 0.
    enum PlaybackError: Int, LocalizedError {
        case cannotLoadResource = 1
        case cannotRenewResource

        var errorDescription: String? {
            switch self {
            case .cannotLoadResource:
                return "Failed to load the resource (custom message)"
            case .cannotRenewResource:
                return "Failed to renew the resource (custom message)"
            }
        }
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadingRequest.finishLoading(with: PlaybackError.cannotLoadResource)
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        renewalRequest.finishLoading(with: PlaybackError.cannotRenewResource)
        return true
    }
}
