//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public enum DownloadState {
    case running
    case suspended
    case canceling
    case partial(PlayerItem)
    case complete(PlayerItem)
    case failed(Error)
}
