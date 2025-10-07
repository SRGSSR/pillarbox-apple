//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

#if os(iOS)

private struct ModalModifier<Item, Presented>: ViewModifier where Item: Identifiable, Presented: View {
    let item: Binding<Item?>
    @ViewBuilder let presented: (Item) -> Presented

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: item) { item in
                presented(item)
                    .modifier(PresentedModifier())
            }
    }
}

private struct PresentedModifier: ViewModifier {
    private let distance: CGFloat = 100
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: distance)
                    .onEnded { value in
                        guard value.translation.height > distance else { return }
                        dismiss()
                    }
            )
            .accessibilityAction(.escape) {
                dismiss()
            }
    }
}

#endif

extension View {
    func modal<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View where Item: Identifiable, Content: View {
#if os(iOS)
        modifier(ModalModifier(item: item, presented: content))
#else
        fullScreenCover(item: item, content: content)
#endif
    }
}
