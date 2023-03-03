//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    var body: some View {
        List(model.medias, id: \.urn) { media in
            Text(media.title)
        }
        .navigationTitle("Search")
        .searchable(text: $model.text)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}
