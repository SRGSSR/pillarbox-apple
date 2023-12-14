//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-hug
struct Cell: View {
    let title: String
    let subtitle: String?
    let style: MediaDescription.Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Self.foregroundColor(for: style))
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
#if os(iOS)
            .frame(maxWidth: .infinity, alignment: .leading)
#else
            .frame(width: 300, height: 250, alignment: .leading)
#endif
        }
    }

    init(title: String, subtitle: String? = nil, style: MediaDescription.Style = .standard, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.action = action
    }

    private static func foregroundColor(for style: MediaDescription.Style) -> Color {
        style == .standard ? .primary : .secondary
    }
}
