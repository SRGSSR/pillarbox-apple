//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

#if DEBUG

private struct DownloadCell: View {
    @EnvironmentObject private var router: Router
    @ObservedObject var download: Download

    var body: some View {
        HStack {
            infoView()
            resumeSuspendButton()
        }
    }

    private func infoView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(download.title)
            ProgressView(value: download.progress)
        }
        .contentShape(.rect)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            switch download.status {
            case let .completed(url):
                router.presented = .player(media: .init(title: download.title, type: .url(url)))
            case .failed:
                download.restart()
            default:
                break
            }
        }
    }

    @ViewBuilder
    private func resumeSuspendButton() -> some View {
        ZStack {
            switch download.status {
            case .running:
                button(systemImage: "pause.circle", action: download.suspend)
            case .suspended:
                button(systemImage: "play.circle", action: download.resume)
            case .completed:
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundStyle(.green)
            case .failed:
                button(systemImage: "arrow.counterclockwise.circle", action: download.restart)
                    .tint(.red)
            }
        }
        .frame(width: 30, height: 30)
        .padding()
    }

    private func button(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
        }
    }
}

struct DownloadsView: View {
    @StateObject private var downloader = Downloader()

    var body: some View {
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
        .toolbar {
            Menu {
                // Warning: Use /ww/ streams only since /ch/-ones are AES-encrypted and cannot be played offline.
                button(
                    title: "Short video",
                    url: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8"
                )
                button(
                    title: "Medium video",
                    url: "https://rts-vod-amd.akamaized.net/ww/cc16c4b0-1c15-326d-958b-faad09e216c1/ffc39d4f-eb00-3979-a5bd-0e3b93b99073/master.m3u8"
                )
                button(
                    title: "Long video",
                    url: "https://rts-vod-amd.akamaized.net/ww/14970442/4dcba1d3-8cc8-3667-a7d2-b3b92c4243d9/master.m3u8"
                )
                button(
                    title: "MP3",
                    url: "https://rts-aod-dd.akamaized.net/ww/13306839/63cc2653-8305-3894-a448-108810b553ef.mp3"
                )
            } label: {
                Image(systemName: "plus")
            }
        }
        .navigationTitle("Downloads")
    }

    private func button(title: String, url: URL) -> some View {
        Button {
            downloader.add(title: title, remoteUrl: url)
        } label: {
            Text(title)
        }
    }
}

#Preview {
    NavigationStack {
        DownloadsView()
    }
}
#endif
