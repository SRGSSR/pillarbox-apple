//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

private struct Cell<Presented: View>: View {
    let title: String
    @ViewBuilder var presented: () -> Presented
    @State private var isPresented = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $isPresented, content: presented)
    }

    private func action() {
        isPresented.toggle()
    }
}

struct ShowcaseView: View {
    var body: some View {
        List {
            Cell(title: "Stories") {
                StoriesView()
            }
            Cell(title: "Twins") {
                TwinsView()
            }
            Cell(title: "Multi") {
                MultiView()
            }
            Cell(title: "Link") {
                LinkView()
            }
        }
        .navigationTitle("Showcase")
    }
}

// MARK: Preview

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShowcaseView()
        }
    }
}
