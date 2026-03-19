//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxCoreBusiness

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

#if DEBUG

struct DownloadsView: View {
    @StateObject private var downloader = Downloader()

    var body: some View {
        ZStack {
            if !downloader.downloads.isEmpty {
                mainView()
            }
            else {
                emptyView()
            }
        }
        .animation(.defaultLinear, value: downloader.downloads)
        .toolbar {
            ToolbarItem {
                removeAllButton()
            }
            ToolbarItem {
                menu()
            }
        }
        .navigationTitle("Downloads")
    }

    private func mainView() -> some View {
        List {
            ForEach(Array(downloader.downloads), id: \.self) { download in
                DownloadCell(download: download)
            }
            .onDelete { indexes in
                for index in indexes.reversed() {
                    downloader.remove(downloader.downloads[index])
                }
            }
        }
    }

    private func emptyView() -> some View {
        UnavailableView {
            Label {
                Text("No downloads.")
            } icon: {
                Image(systemName: "square.and.arrow.down")
            }
        }
    }

    private func menu() -> some View {
        Menu {
            // Warning: Use /ww/ streams only since /ch/-ones are AES-encrypted and cannot be played offline.
            addDownloadButton(for: .init(
                title: "Short video",
                type: .url("https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8")
            ))
            addDownloadButton(for: .init(
                title: "Medium video",
                type: .url("https://rts-vod-amd.akamaized.net/ww/cc16c4b0-1c15-326d-958b-faad09e216c1/ffc39d4f-eb00-3979-a5bd-0e3b93b99073/master.m3u8")
            ))
            addDownloadButton(for: .init(
                title: "Long video",
                type: .url("https://rts-vod-amd.akamaized.net/ww/14970442/4dcba1d3-8cc8-3667-a7d2-b3b92c4243d9/master.m3u8")
            ))
            addDownloadButton(for: .init(
                title: "MP3",
                type: .url("https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3")
            ))
            addDownloadButton(for: .init(
                title: "URN",
                type: .urn("urn:rts:video:7144dae0-bdc3-31c6-b84f-1263abe0f92e")
            ))
        } label: {
            Image(systemName: "plus")
        }
    }

    private func addDownloadButton(for media: Media) -> some View {
        Button {
            switch media.type {
            case let .url(url), let .monoscopicUrl(url), let .unbufferedUrl(url):
                downloader.add(asset: .simple(url: url, metadata: media))
            case let .tokenProtectedUrl(url):
                downloader.add(asset: .tokenProtected(url: url, metadata: media))
            case let .encryptedUrl(url, certificateUrl: certificateUrl):
                downloader.add(asset: .encrypted(url: url, certificateUrl: certificateUrl, metadata: media))
            case let .urn(urn, serverSetting: serverSetting):
                downloader.add(urn: urn, server: serverSetting.server)
            case .item:
                break
            }
        } label: {
            Text(media.title)
        }
    }

    @ViewBuilder
    private func removeAllButton() -> some View {
        if !downloader.downloads.isEmpty {
            Button(action: downloader.removeAll) {
                Image(systemName: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        DownloadsView()
    }
}

#endif
