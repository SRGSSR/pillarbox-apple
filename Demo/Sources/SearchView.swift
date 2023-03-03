//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SearchView: View {
    @State private var text = ""
    var body: some View {
        List {
            Text("Test 1")
            Text("Test 2")
        }
        .navigationTitle("Search")
        .searchable(text: $text)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}
