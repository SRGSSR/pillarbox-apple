//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

#if os(iOS)

private struct PresentedModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 100)
                    .onEnded { value in
                        guard value.translation.height > 0 else { return }
                        dismiss()
                    }
            )
    }
}

private struct ModalModifier<Presented>: ViewModifier where Presented: View {
    let destination: Binding<RouterDestination?>
    @ViewBuilder let presented: (RouterDestination) -> Presented

    private var fullScreenCoverDestination: Binding<RouterDestination?> {
        isFullScreenCover ? destination : .constant(nil)
    }

    private var sheetDestination: Binding<RouterDestination?> {
        !isFullScreenCover ? destination : .constant(nil)
    }

    private var isFullScreenCover: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return true }
        return destination.wrappedValue?.preferredModal == .fullScreenCover
    }

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: fullScreenCoverDestination) { item in
                presented(item)
                    .modifier(PresentedModifier())
            }
            .sheet(item: sheetDestination, content: presented)
    }
}

#endif

extension View {
    func modal<Content>(
        destination: Binding<RouterDestination?>,
        @ViewBuilder content: @escaping (RouterDestination) -> Content
    ) -> some View where Content: View {
#if os(iOS)
        modifier(ModalModifier(destination: destination, presented: content))
#else
        fullScreenCover(item: item, content: content)
#endif
    }
}
