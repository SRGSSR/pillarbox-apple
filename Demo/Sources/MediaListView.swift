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
            case let .failed(error):
                Text(error.localizedDescription)
            }
        }
        .navigationTitle("Medias")
    }
}
