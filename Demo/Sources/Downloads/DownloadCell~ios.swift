//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

@_spi(DownloaderPrivate)
import PillarboxPlayer

import SwiftUI

struct DownloadCell: View {
    @ObservedObject var download: Download

    private(set) var action: () -> Void

    private var title: String {
        download.metadata.title ?? "Untitled"
    }

    private var subtitle: String? {
        download.metadata.subtitle
    }

    var body: some View {
        HStack {
            infoView()
            statusButton()
        }
    }

    private func infoView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            descriptionView()
            progressBar()
            errorMessage()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityAddTraits(.isButton)
        .onTapGesture(perform: action)
    }

    private func descriptionView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func progressBar() -> some View {
        ProgressView(value: download.progress) {
            Text(download.progress, format: .percent.precision(.fractionLength(0)))
                .contentTransition(.numericText())
        }
        .animation(.linear, value: download.progress)
    }

    @ViewBuilder
    private func errorMessage() -> some View {
        if let error = download.error {
            Text(error.localizedDescription)
                .foregroundStyle(.red)
        }
    }

    private func statusButton() -> some View {
        ZStack {
            switch download.state {
            case .preparing:
                ProgressView()
            case .running:
                button(systemImage: "pause.circle", action: download.suspend)
            case .suspended:
                button(systemImage: "play.circle", action: download.resume)
            case .completed:
                completedButton()
            }
        }
        .frame(width: 30, height: 30)
        .padding()
    }

    @ViewBuilder
    private func completedButton() -> some View {
        if download.error != nil {
            button(systemImage: "arrow.counterclockwise.circle", action: download.restart)
                .tint(.red)
        }
        else {
            Image(systemName: "checkmark")
                .resizable()
                .foregroundStyle(.green)
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
