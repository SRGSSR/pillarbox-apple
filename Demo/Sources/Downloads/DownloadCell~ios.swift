//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

#if DEBUG

struct DownloadCell<L>: View where L: AssetLoader {
    @ObservedObject var download: Download<L>
    @EnvironmentObject private var router: Router

    private var title: String {
        download.metadata().title ?? "Untitled"
    }

    var body: some View {
        HStack {
            infoView()
            statusButton()
        }
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
            if let item = download.playerItem() {
                // router.presented = .player
            }
            else {
                switch download.state {
                case .failed:
                    download.restart()
                default:
                    break
                }
            }
        }
    }

    private func statusButton() -> some View {
        ZStack {
            switch download.state {
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

#endif
