//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct AdaptiveSheetContainer<Content, Sheet>: View where Content: View, Sheet: View {
    @Binding var isPresenting: Bool

    @ViewBuilder let content: () -> Content
    @ViewBuilder let sheet: () -> Sheet

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        switch horizontalSizeClass {
        case .compact:
            compactView()
        default:
            defaultView()
        }
    }

    private func compactView() -> some View {
        content()
            .sheet(isPresented: $isPresenting) {
                NavigationStack {
                    sheet()
                }
                .presentationDetents([.medium, .large])
            }
    }

    private func defaultView() -> some View {
        HStack(spacing: 0) {
            content()
            if isPresenting {
                NavigationStack {
                    sheet()
                        .toolbar(content: toolbarContent)
                }
                .frame(width: 420)
            }
        }
        .animation(.default, value: isPresenting)
    }

    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Hide", action: close)
        }
    }

    private func close() {
        isPresenting = false
    }
}
