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
    private let _urlDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! URLDownloader(name: "url_downloads", configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.url-downloads"))
    }()

    private let _urnDownloader: Any? = {
        guard #available(iOS 17, *) else { return nil }
        return try! URNDownloader(name: "urn_downloads", configuration: .background(withIdentifier: "ch.srgssr.pillarbox-demo.urn-downloads"))
    }()

    @available(iOS 17, *)
    private var urlDownloader: URLDownloader<EmptyCustomData> {
        _urlDownloader as! URLDownloader
    }

    @available(iOS 17, *)
    private var urnDownloader: URNDownloader {
        _urnDownloader as! URNDownloader
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
        Publishers.CombineLatest(urlDownloader.$downloads, urnDownloader.$downloads)
            .map { $0 + $1 }
            .assign(to: &$_downloads)
    }

    func addDownload(media: Media) {
        guard #available(iOS 17, *) else { return }
        switch media.type {
        case let .url(url), let .monoscopicUrl(url):
            urlDownloader.addDownload(url: url, metadata: media.metadata(), configuration: UserDefaults.standard.downloadConfiguration)
        case let .urn(urn, serverSetting):
            urnDownloader.addDownload(urn: urn, server: serverSetting.server, configuration: UserDefaults.standard.downloadConfiguration)
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
        else {
            return nil
        }
    }

    func removeDownload(_ download: Download) {
        guard #available(iOS 17, *) else { return }
        urlDownloader.removeDownload(download)
        urnDownloader.removeDownload(download)
    }

    func removeAllDownloads() {
        guard #available(iOS 17, *) else { return }
        urlDownloader.removeAllDownloads()
        urnDownloader.removeAllDownloads()
    }
}

#endif
