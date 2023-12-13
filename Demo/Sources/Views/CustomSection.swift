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
                HStack(spacing: 30, content: content)
                    .padding(15)
            }
        } header: {
            header()
                .padding(.vertical, -15)
                .padding(.top, 10)
        }
#endif
    }
}

extension CustomSection where Header == Text {
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.init {
            content()
        } header: {
            Text(title)
        }
    }
}
