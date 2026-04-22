//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

#if DEBUG

struct DownloadCell: View {
    @ObservedObject var download: Download
    @EnvironmentObject private var router: Router

    var body: some View {
        HStack {
            infoView()
            statusButton()
        }
    }

    var title: String {
        download.title() ?? "Untitled"
    }

    private func infoView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
            ProgressView(value: download.progress) {
                Text(download.progress, format: .percent.precision(.fractionLength(0)))
                    .contentTransition(.numericText())
            }
            .animation(.linear, value: download.progress)
        }
        .contentShape(.rect)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            switch download.file {
            case let .partial(url), let .complete(url):
                router.presented = .player(media: .init(title: title, type: .url(url)))
            case .failed:
                download.restart()
            default:
                break
            }
        }
    }

    private func statusButton() -> some View {
        ZStack {
            switch download.file {
            case .failed:
                button(systemImage: "arrow.counterclockwise.circle", action: download.restart)
                    .tint(.red)
            default:
                resumeSuspendButton()
            }
        }
        .frame(width: 30, height: 30)
        .padding()
    }

    @ViewBuilder
    private func resumeSuspendButton() -> some View {
        switch download.state {
        case .running:
            button(systemImage: "pause.circle", action: download.suspend)
        case .suspended:
            button(systemImage: "play.circle", action: download.resume)
        case .completed:
            Image(systemName: "checkmark")
                .resizable()
                .foregroundStyle(.green)
        default:
            EmptyView()
        }
    }

    private func button(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
        }
    }
}

#endif
