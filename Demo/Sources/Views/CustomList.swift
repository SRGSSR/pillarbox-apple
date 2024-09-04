//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CustomList<Content, Data>: View where Content: View, Data: Hashable {
    let data: [Data]
    @ViewBuilder let content: (Data?) -> Content

    var body: some View {
#if os(iOS)
        if !data.isEmpty {
            List(data, id: \.self, rowContent: content)
        }
        else {
            List { content(nil) }
        }
#else
        ScrollView {
            if !data.isEmpty {
                LazyVGrid(columns: (0..<3).map { _ in GridItem(.flexible()) }, spacing: 50) {
                    ForEach(data, id: \.self, content: content)
                }
                .padding(.horizontal, 50)
            }
            else {
                VStack(alignment: .leading) {
                    content(nil)
                }
            }
        }
#endif
    }
}

extension CustomList where Data == Never {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = { _ in content() }
        data = []
    }
}
