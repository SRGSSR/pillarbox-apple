//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct ListsView: View {
    @StateObject var listsViewModel = ListsViewModel()

    var body: some View {
        NavigationStack {
            List {
                section(title: "Latest Videos", contents: ["SRF", "RTS", "RSI", "RTR", "SWI"])
            }
            .navigationTitle("Lists")
        }
    }

    @ViewBuilder
    private func section(title: String, contents: [String]) -> some View {
        Section(title) {
            ForEach(contents, id: \.self) { content in
                NavigationLink(content) {
                    EmptyView()
                }
            }
        }
    }
}
