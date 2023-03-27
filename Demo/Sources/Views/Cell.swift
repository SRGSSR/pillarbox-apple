//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-hug
struct Cell<Content: View, Presented: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var presented: () -> Presented
    @State private var isPresented = false

    var body: some View {
        Button(action: action, label: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .sheet(isPresented: $isPresented, content: presented)
    }

    private func action() {
        isPresented.toggle()
    }
}

extension Cell where Content == VStack<TupleView<(Text, Text?)>> {
    init(
        title: String,
        subtitle: String? = nil,
        style: MediaDescription.Style = .standard,
        @ViewBuilder presented: @escaping () -> Presented
    ) {
        self.init(
            content: {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(Self.foregroundColor(for: style))
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            },
            presented: presented
        )
    }

    private static func foregroundColor(for style: MediaDescription.Style) -> Color {
        style == .standard ? .primary : .secondary
    }
}
