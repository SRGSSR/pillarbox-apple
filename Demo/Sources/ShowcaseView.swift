//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

struct ShowcaseView: View {
    var body: some View {
        List {
            StoriesCell()
            TwinsCell()
        }
        .navigationTitle("Showcase")
    }
}

// MARK: Entries

// TODO: Use generics to write single cell

private struct StoriesCell: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: action) {
            Text("Stories")
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $isPresented) {
            StoriesView()
        }
    }

    private func action() {
        isPresented.toggle()
    }
}

private struct TwinsCell: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: action) {
            Text("Twin players")
                .foregroundColor(.primary)
        }
        .sheet(isPresented: $isPresented) {
            TwinsView()
        }
    }

    private func action() {
        isPresented.toggle()
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
