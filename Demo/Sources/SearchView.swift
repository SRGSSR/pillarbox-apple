//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(medias: medias):
                List(medias, id: \.urn) { media in
                    Text(media.title)
                }
            case let .failed(error):
                Text(error.localizedDescription)
            }
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
