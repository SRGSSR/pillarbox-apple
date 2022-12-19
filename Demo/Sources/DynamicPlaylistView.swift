//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct DynamicPlaylistView: View {
    @State var medias: [Media]

    var body: some View {
        VStack(spacing: 0) {
            PlayerView(medias: medias)
            DynamicListView(medias: medias)
        }
    }
}

// Behavior: h-exp, v-exp
private struct DynamicListView: View {
    let medias: [Media]
    
    var body: some View {
        List(medias) { media in
            switch media {
            case .empty:
                EmptyView()
            case .url(let url), .unbufferedUrl(let url):
                Text(url.absoluteString)
            case .urn(let urn):
                Text(urn)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: Previews

struct DynamicPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicPlaylistView(medias: [
            MediaURL.onDemandVideoLocalHLS,
            MediaURL.onDemandVideoLocalHLS,
        ])
    }
}
