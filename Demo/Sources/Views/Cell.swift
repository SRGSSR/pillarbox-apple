//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct Cell: View {
    let size: CGSize
    let title: String?
    let subtitle: String?
    let imageUrl: URL?
    let type: String?
    let duration: String?
    let date: String?
    let style: MediaDescription.Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
#if os(iOS)
            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .foregroundColor(Self.foregroundColor(for: style))
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement()
            .accessibilityLabel(title ?? "")
#else
            MediaCardView(
                size: size,
                title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                type: type,
                duration: duration,
                date: date
            )
#endif
        }
#if os(tvOS)
        .buttonStyle(.card)
#endif
    }

    init(
        size: CGSize = .init(width: 450, height: 250),
        title: String?,
        subtitle: String? = nil,
        imageUrl: URL? = nil,
        type: String? = nil,
        duration: String? = nil,
        date: String? = nil,
        style: MediaDescription.Style = .standard,
        action: @escaping () -> Void
    ) {
        self.size = size
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.type = type
        self.duration = duration
        self.date = date
        self.style = style
        self.action = action
    }

    private static func foregroundColor(for style: MediaDescription.Style) -> Color {
        style == .standard ? .primary : .secondary
    }
}
