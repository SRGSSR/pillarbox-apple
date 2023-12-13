//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CustomSection<Content>: View where Content: View {
    let title: any StringProtocol
    @ViewBuilder let content: () -> Content

    var body: some View {
#if os(iOS)
        Section {
            content()
        } header: {
            Text(title)
        }
#else
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 30, content: content)
                    .padding(15)
            }
        } header: {
            Text(title)
                .padding(.vertical, -15)
                .padding(.top, 10)
        }
#endif
    }
}
