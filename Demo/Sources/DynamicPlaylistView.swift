//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct DynamicPlaylistView: View {
    let medias: [Media]

    var body: some View {
        VStack {
            PlayerView(medias: medias)
            DynamicListView()
        }
    }
}

// Behavior: h-exp, v-exp
private struct DynamicListView: View {
    var body: some View {
        List {
            Text("azerty")
        }
    }
}

// MARK: Previews

struct DynamicPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicPlaylistView(medias: [MediaURL.onDemandVideoLocalHLS])
    }
}
