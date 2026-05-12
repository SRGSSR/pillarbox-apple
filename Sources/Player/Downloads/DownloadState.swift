//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
public enum DownloadState {
    case unknown
    case running
    case suspended
    case completed
    case failed(Error)
}
