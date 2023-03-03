//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
            case let .loaded(medias: medias):
                loadedView(medias)
            case let .failed(error):
                Text(error.localizedDescription)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $model.text)
    }

    @ViewBuilder
    func loadedView(_ medias: [SRGMedia]) -> some View {
        if !medias.isEmpty {
            List(medias, id: \.urn) { media in
                Text(media.title)
            }
        }
        else if model.text.isEmpty {
            Text("Enter something to search.")
        }
        else {
            Text("No results.")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}
