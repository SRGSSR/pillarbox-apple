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
                }
                .refreshable { model.refresh() }
            case let .failed(error):
                ScrollView {
                    Text(error.localizedDescription)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .refreshable { model.refresh() }
            }
        }
        .navigationTitle("Medias")
    }
}
