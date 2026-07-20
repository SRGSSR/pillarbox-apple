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

    private var imageSource: ImageSource {
        download.metadata.imageSource
    }

    var body: some View {
        HStack {
            infoView()
            DownloadButton(download: download, side: 32)
        }
    }

    private func artworkView() -> some View {
        Rectangle()
            .foregroundStyle(.quaternary)
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(height: 32)
            .overlay {
                LazyImage(source: imageSource) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
    }

    private func infoView() -> some View {
        HStack {
            artworkView()
            descriptionView()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityAddTraits(.isButton)
        .onTapGesture(perform: action)
    }

    private func descriptionView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .lineLimit(1)
            if let subtitle {
                Text(subtitle)
                    .lineLimit(2)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#endif
