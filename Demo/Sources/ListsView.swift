//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ListsView: View {
    var body: some View {
        List {
            section(title: "Topics TV", contents: ["Play MMF", "SRF", "RTS", "RSI", "RTR", "SWI"])
            section(title: "Live TV", contents: ["SRF", "RTS", "RSI", "RTR"])
        }
        .navigationTitle("Lists")
    }

    @ViewBuilder
    private func section(title: String, contents: [String]) -> some View {
        Section(title) {
            ForEach(contents, id: \.self) { content in
                Text(content)
            }
        }
    }
}
