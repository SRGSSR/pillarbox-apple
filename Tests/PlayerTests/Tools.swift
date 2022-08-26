//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum TestError: Error {
    case any
}

enum TestStreams {
    static let onDemandUrl = URL(string: "http://localhost:8000/on_demand/master.m3u8")!
    static let shortOnDemandUrl = URL(string: "http://localhost:8000/on_demand_short/master.m3u8")!
    static let corruptOnDemandUrl = URL(string: "http://localhost:8000/on_demand_corrupt/master.m3u8")!

    static let liveUrl = URL(string: "http://localhost:8000/live/master.m3u8")!
    static let dvrUrl = URL(string: "http://localhost:8000/dvr/master.m3u8")!

    static let unavailableUrl = URL(string: "http://localhost:8000/unavailable/master.m3u8")!
    static let customUrl = URL(string: "custom://arbitrary.server/some.m3u8")!
}

final class TestNSObject: NSObject {
}

final class TestObject {
}

struct TestStruct {
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

extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}
