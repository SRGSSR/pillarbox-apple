//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct CustomGrid<Content, Data>: View where Content: View, Data: Hashable {
    let columns: Int = 4
    let data: [Data]
    @ViewBuilder let content: (Data?) -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            let rows = data.count / columns + 1
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { column in
                        let index = row * columns + column
                        if index < data.count {
                            content(data[index])
                        }
                    }
                }
            }
        }
    }
}

struct CustomList<Content, Data>: View where Content: View, Data: Hashable {
    let data: [Data]
    @ViewBuilder let content: (Data?) -> Content

    var body: some View {
#if os(iOS)
        if !data.isEmpty {
            List(data, id: \.self, rowContent: content)
        } else {
            List { content(nil) }
        }
#else
        ScrollView {
            if !data.isEmpty {
                CustomGrid(data: data, content: content)
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
    init(content: @escaping () -> Content) {
        self.content = { _ in content() }
        data = []
    }
}
