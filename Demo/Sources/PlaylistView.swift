//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct PlaylistView: View {
    let medias: [Media]

    var body: some View {
        PlayerView(medias: medias)
    }

    init(medias: [Media]) {
        self.medias = medias
    }
}

// MARK: Previews

struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(medias: [MediaURL.onDemandVideoLocalHLS])
    }
}
