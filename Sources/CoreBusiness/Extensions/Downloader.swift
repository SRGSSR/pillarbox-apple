//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public extension Downloader {
    @discardableResult
    func add(urn: String, server: Server = .production) -> Download {
        fatalError("Not implemented yet")
    }
}
