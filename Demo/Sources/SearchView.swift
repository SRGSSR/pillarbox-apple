//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

private struct MessageView: View {
    @ObservedObject var model: SearchViewModel
    let message: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
    }
}

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
                MessageView(model: model, message: error.localizedDescription)
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
                    .onAppear {
                        if let index = medias.firstIndex(of: media), medias.count - index < kPageSize {
                            model.loadMore()
                        }
                    }
            }
            .refreshable { await model.refresh() }
        }
        else if model.text.isEmpty {
            Text("Enter something to search.")
        }
        else {
            MessageView(model: model, message: "No results.")
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
