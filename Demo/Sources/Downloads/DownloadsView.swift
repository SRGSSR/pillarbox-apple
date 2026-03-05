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

    let downloader: Downloader
    @ObservedObject var download: Download

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(download.title)
                ProgressBar(download: download)
                if let fileUrl = downloader.fileUrl(for: download) {
                    Text(fileUrl.absoluteString)
                        .font(.footnote)
                }
            }
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                if let fileUrl = downloader.fileUrl(for: download) {
                    router.presented = .player(media: .init(title: download.title, type: .url(fileUrl)))
                }
            }
            resumeSuspendButton()
        }
    }

    @ViewBuilder
    func resumeSuspendButton() -> some View {
        switch download.state {
        case .suspended:
            Button {
                download.resume()
            } label: {
                Image(systemName: "play.circle")
                    .resizable()
            }
            .frame(width: 40, height: 40)
        case .running:
            Button {
                download.suspend()
            } label: {
                Image(systemName: "pause.circle")
                    .resizable()
            }
            .frame(width: 40, height: 40)
        case .canceling:
            Text("Cancelled")
                .foregroundStyle(.red)
        case .completed:
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
        default:
            EmptyView()
        }
    }
}

private struct ProgressBar: View {
    @ObservedObject var download: Download

    var body: some View {
        ProgressView(value: download.progress)
    }
}

struct DownloadsView: View {
    @StateObject private var downloader = Downloader()

    var body: some View {
        List {
            ForEach(Array(downloader.downloads), id: \.self) { download in
                DownloadCell(downloader: downloader, download: download)
            }
            .onDelete { indexes in
                for index in indexes.reversed() {
                    downloader.remove(downloader.downloads[index])
                }
            }
        }
        .toolbar {
            Menu {
                button(
                    title: "Short video",
                    url: "https://rts-vod-amd.akamaized.net/ww/13317145/f1d49f18-f302-37ce-866c-1c1c9b76a824/master.m3u8"
                )
                button(
                    title: "Medium video",
                    url: "https://rts-vod-amd.akamaized.net/ch/056275f8-8f6e-370b-a628-4451b4f17d88/cb31e20a-a245-39d4-bb31-990ff850138b/master.m3u8"
                )
                button(
                    title: "Long video",
                    url: "https://rts-vod-amd.akamaized.net/ww/14970442/4dcba1d3-8cc8-3667-a7d2-b3b92c4243d9/master.m3u8"
                )
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private func button(title: String, url: URL) -> some View {
        Button {
            downloader.add(title: title, url: url)
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
