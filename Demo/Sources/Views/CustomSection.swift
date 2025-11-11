//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CustomSection<Content, Header>: View where Content: View, Header: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let header: () -> Header

    var body: some View {
#if os(iOS)
        Section {
            content()
        } header: {
            header()
        }
#else
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 50, content: content)
                    .padding(50)
            }
        } header: {
            header()
                .headerStyle()
                .padding(.bottom, -50)
        }
#endif
    }
}

extension CustomSection where Header == Text {
    init(_ title: LocalizedStringResource, @ViewBuilder content: @escaping () -> Content) {
        self.init {
            content()
        } header: {
            Text(title)
        }
    }
}
