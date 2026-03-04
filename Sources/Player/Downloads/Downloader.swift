//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

#if DEBUG
@_spi(DownloaderPrivate)
public final class Downloader: ObservableObject {
    @Published private var _downloads: Set<Download> = []

    private lazy var session = AVAssetDownloadURLSession(
        configuration: .background(withIdentifier: "ch.srgssr.player.downloader"),
        assetDownloadDelegate: nil,
        delegateQueue: nil
    )

    public var downloads: [Download] {
        Array(_downloads.sorted(using: KeyPathComparator(\.title)))
    }

    public init() {}

    @discardableResult
    public func add(title: String, url: URL) -> Download {
        let download = Download(title: title, url: url, session: session)
        _downloads.insert(download)
        return download
    }

    public func remove(_ download: Download) {
        _downloads.remove(download)
    }
}
#endif
