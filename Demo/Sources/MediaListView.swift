//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

struct MediaListView: View {
    @StateObject private var model = MediaListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
            case let .loaded(medias: medias):
                List(medias, id: \.urn) { media in
                    Text(media.title)
                        .onAppear {
                            if medias.last == media {
                                model.loadMore()
                            }
                        }
                }
                .refreshable { await model.refresh() }
            case let .failed(error):
                GeometryReader { geometry in
                    ScrollView {
                        Text(error.localizedDescription)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .refreshable { await model.refresh() }
                }
            }
        }
        .navigationTitle("Medias")
    }
}
