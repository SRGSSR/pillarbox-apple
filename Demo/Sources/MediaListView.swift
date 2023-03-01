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
        List(model.medias, id: \.urn) { media in
            Text(media.title)
        }
        .navigationTitle("Medias")
    }
}
