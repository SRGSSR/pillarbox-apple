//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

final class DemoDownloader: ObservableObject {
    private let urlDownloader = Downloader(
        assetLoaderType: URLAssetLoader.self,
        mapperType: URLAssetMapper.self,
        configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads"),
        store: URLAssetDownloadStore(fileName: "file_downloads.json")
    )

    private let _urnDownloader: Any? = {
        if #available(iOS 17, *) {
            Downloader(
                assetLoaderType: URNAssetLoader.self,
                mapperType: URNAssetMapper.self,
                configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"),
                store: URNAssetDownloadStore()
            )
        }
        else {
            nil
        }
    }()

    @available(iOS 17, *)
    private var urnDownloader: Downloader<URNAssetDownloadStore>? {
        _urnDownloader as? Downloader<URNAssetDownloadStore>
    }

    @Published private(set) var downloads: [Download] = []

    init() {
        if #available(iOS 17, *), let urnDownloader {
            Publishers.CombineLatest(
                urlDownloader.$downloads,
                urnDownloader.$downloads
            )
            .map { $0 + $1 }
            .assign(to: &$downloads)
        }
        else {
            urlDownloader.$downloads
                .assign(to: &$downloads)
        }
    }

    func addUrlDownload(title: String, url: URL) {
        urlDownloader.addDownload(for: .init(title: title, url: url))
    }

    @available(iOS 17, *)
    func addUrnDownload(urn: String, serverSetting: ServerSetting) {
        urnDownloader?.addDownload(for: .init(urn: urn, server: serverSetting.server, configuration: .default))
    }

    func playerItem(for download: Download) -> PlayerItem? {
        if let item = urlDownloader.playerItem(for: download) {
            return item
        }
        else if #available(iOS 17, *), let urnDownloader, let item = urnDownloader.playerItem(for: download) {
            return item
        }
        else {
            return nil
        }
    }

    func removeDownload(_ download: Download) {
        urlDownloader.removeDownload(download)
        if #available(iOS 17, *) {
            urnDownloader?.removeDownload(download)
        }
    }

    func removeAllDownloads() {
        urlDownloader.removeAllDownloads()
        if #available(iOS 17, *) {
            urnDownloader?.removeAllDownloads()
        }
    }
}
