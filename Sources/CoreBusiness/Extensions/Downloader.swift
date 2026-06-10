//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
@available(iOS 17.0, *)
public typealias URNDownloader = Downloader<URNAssetDownloadStore>

@available(iOS 17.0, *)
public extension URNDownloader {
    convenience init(configuration: URLSessionConfiguration) {
        self.init(
            assetLoaderType: URNAssetLoader.self,
            storableMetadata: Downloader.storableMetadata,
            configuration: configuration,
            store: URNAssetDownloadStore()
        )
    }

    private static func storableMetadata(_ metadata: MediaMetadata) -> URNAssetDownloadStore.EntryMetadata {
        .init(
            identifier: metadata.mainChapter.urn,
            title: metadata.title,
            subtitle: metadata.subtitle
        )
    }

    func addDownload(urn: String, server: Server = .production) {
        addDownload(for: .init(urn: urn, server: server))
    }

    func download(urn: String, server: Server) -> Download? {
        download(matching: .init(urn: urn, server: server))
    }
}

#endif

// swiftlint:enable missing_docs
