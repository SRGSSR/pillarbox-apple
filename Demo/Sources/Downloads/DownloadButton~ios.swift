//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

private struct DownloadIcon: View {
    enum State {
        case running(Double)
        case suspended(Double)
        case completed
        case failed
    }

    let state: State
    let side: CGFloat

    var body: some View {
        switch state {
        case let .running(progress):
            CircularProgressIcon(progress: progress, icon: "pause.fill", side: side)
        case let .suspended(progress):
            CircularProgressIcon(progress: progress, icon: "play.fill", side: side)
        case .completed:
            CircularProgressIcon(progress: 1, icon: "checkmark", color: .green, side: side)
        case .failed:
            CircularProgressIcon(progress: 1, icon: "arrow.counterclockwise", color: .red, side: side)
        }
    }
}

struct DownloadButton: View {
    @ObservedObject var download: Download
    let side: CGFloat

    var body: some View {
        ZStack {
            if download.error != nil {
                Button(action: download.restart) {
                    DownloadIcon(state: .failed, side: side)
                }
            }
            else {
                switch download.state {
                case .preparing:
                    ProgressView()
                        .frame(width: side, height: side)
                case .running:
                    Button(action: download.suspend) {
                        DownloadIcon(state: .running(download.progress), side: side)
                    }
                case .suspended:
                    Button(action: download.resume) {
                        DownloadIcon(state: .suspended(download.progress), side: side)
                    }
                case .completed:
                    DownloadIcon(state: .completed, side: side)
                }
            }
        }
        .animation(.default, value: download.progress)
    }
}

#Preview {
    VStack(spacing: 20) {
        DownloadIcon(state: .completed, side: 100)
        DownloadIcon(state: .failed, side: 100)
        DownloadIcon(state: .running(0.3), side: 100)
        DownloadIcon(state: .suspended(0.5), side: 100)
    }
}

#endif
