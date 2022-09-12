//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

struct ShowcaseView: View {
    @State private var isPresented = false

    private func action() {
        isPresented.toggle()
    }

    var body: some View {
        List {
            Button(action: action) {
                Text("Stories")
                    .foregroundColor(.primary)
            }
        }
        .navigationTitle("Showcase")
        .sheet(isPresented: $isPresented) {
            StoriesView()
        }
    }
}

// MARK: Preview

struct ShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseView()
    }
}
