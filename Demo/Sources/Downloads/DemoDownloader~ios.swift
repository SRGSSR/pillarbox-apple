//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

@_spi(DownloaderPrivate)
import PillarboxPlayer

@available(tvOS, unavailable)
final class DemoDownloader: ObservableObject {
    private let urlDownloader = Downloader(
        assetLoaderType: URLAssetLoader.self,
        configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads"),
        store: URLAssetDownloadStore(fileName: "url_downloads.json")
    )

    private let _urnDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! URNDownloader(configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"))
    }()

    @available(iOS 17, *)
    private var urnDownloader: URNDownloader {
        _urnDownloader as! URNDownloader
    }

    @Published private var _downloads: [Download] = []

    var downloads: [Download] {
        _downloads.sorted { $0.creationDate > $1.creationDate }
    }

    init() {
        if #available(iOS 17, *) {
            Publishers.CombineLatest(
                urlDownloader.$downloads,
                urnDownloader.$downloads
            )
            .map { $0 + $1 }
            .assign(to: &$_downloads)
        }
        else {
            urlDownloader.$downloads
                .assign(to: &$_downloads)
        }
    }

    func canDownload(media: Media) -> Bool {
        switch media.type {
        case .url, .monoscopicUrl:
            true
        case .urn:
            _urnDownloader != nil
        default:
            false
        }
    }

    func addDownload(media: Media) {
        switch media.type {
        case let .url(url), let .monoscopicUrl(url):
            urlDownloader.addDownload(for: .init(url: url, metadata: media.metadata()))
        case let .urn(urn, serverSetting):
            if #available(iOS 17, *) {
                urnDownloader.addDownload(urn: urn, server: serverSetting.server)
            }
        default:
            break
        }
    }

    func playerItem(for download: Download) -> PlayerItem? {
        if let item = urlDownloader.playerItem(for: download) {
            return item
        }
        else if #available(iOS 17, *), let item = urnDownloader.playerItem(for: download) {
            return item
        }
        else {
            return nil
        }
    }

    func removeDownload(_ download: Download) {
        urlDownloader.removeDownload(download)
        if #available(iOS 17, *) {
            urnDownloader.removeDownload(download)
        }
    }

    func removeAllDownloads() {
        urlDownloader.removeAllDownloads()
        if #available(iOS 17, *) {
            urnDownloader.removeAllDownloads()
        }
    }
}

#endif
