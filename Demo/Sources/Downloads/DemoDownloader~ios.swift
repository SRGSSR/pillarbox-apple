//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DOWNLOADS

import Combine
import Foundation

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

@_spi(DownloaderPrivate)
import PillarboxPlayer

@_spi(DownloaderPrivate)
import PillarboxStandardConnector

@available(tvOS, unavailable)
final class DemoDownloader: ObservableObject {
    private let _urlDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! URLDownloader(
            name: "url_downloads",
            storeProviderType: MediaAssetProvider.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads")
        )
    }()

    private let _urnDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! URNDownloader(name: "urn_downloads", configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"))
    }()

    private let _standardDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! StandardDownloader(
            name: "standard_downloads",
            storeProviderType: DemoAssetProvider.self,
            configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.standard-downloads")
        )
    }()

    @available(iOS 17, *)
    private var urlDownloader: URLDownloader<MediaCustomData> {
        _urlDownloader as! URLDownloader
    }

    @available(iOS 17, *)
    private var urnDownloader: URNDownloader {
        _urnDownloader as! URNDownloader
    }

    @available(iOS 17, *)
    private var standardDownloader: StandardDownloader<DemoAssetProvider> {
        _standardDownloader as! StandardDownloader
    }

    var canDownload: Bool {
        if #available(iOS 17, *) {
            return true
        }
        else {
            return false
        }
    }

    @Published private var _downloads: [Download] = []

    var downloads: [Download] {
        _downloads.sorted { $0.creationDate > $1.creationDate }
    }

    init() {
        guard #available(iOS 17, *) else { return }
        Publishers.CombineLatest3(urlDownloader.$downloads, urnDownloader.$downloads, standardDownloader.$downloads)
            .map { $0 + $1 + $2 }
            .assign(to: &$_downloads)
    }

    func addDownload(media: Media) {
        guard #available(iOS 17, *) else { return }
        let configuration = UserDefaults.standard.downloadConfiguration
        switch media.kind {
        case let .url(url, customData: customData):
            urlDownloader.addDownload(url: url, metadata: media.metadata(customData: customData), configuration: configuration)
        case let .urn(urn, serverSetting: serverSetting):
            urnDownloader.addDownload(urn: urn, server: serverSetting.server, configuration: configuration)
        case let .demo(identifier, isProduction: isProduction):
            standardDownloader.addDownload(for: .init(identifier: identifier, isProduction: isProduction), configuration: configuration)
        default:
            break
        }
    }

    func playerItem(for download: Download) -> PlayerItem? {
        guard #available(iOS 17, *) else { return nil }
        if let item = urlDownloader.playerItem(for: download) {
            return item
        }
        else if let item = urnDownloader.playerItem(for: download) {
            return item
        }
        else if let item = standardDownloader.playerItem(for: download) {
            return item
        }
        else {
            return nil
        }
    }

    func removeDownload(_ download: Download) {
        guard #available(iOS 17, *) else { return }
        urlDownloader.removeDownload(download)
        urnDownloader.removeDownload(download)
        standardDownloader.removeDownload(download)
    }

    func removeAllDownloads() {
        guard #available(iOS 17, *) else { return }
        urlDownloader.removeAllDownloads()
        urnDownloader.removeAllDownloads()
        standardDownloader.removeAllDownloads()
    }
}

#endif
