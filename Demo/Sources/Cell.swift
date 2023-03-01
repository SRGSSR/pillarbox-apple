//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-hug, v-hug
struct Cell<Content: View, Presented: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var presented: () -> Presented
    @State private var isPresented = false

    var body: some View {
        Button(action: action, label: content)
            .sheet(isPresented: $isPresented, content: presented)
    }

    private func action() {
        isPresented.toggle()
    }
}

extension Cell where Content == VStack<TupleView<(Text, Text?)>> {
    init(title: String, subtitle: String? = nil, @ViewBuilder presented: @escaping () -> Presented) {
        self.init(
            content: {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.primary)
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
}
