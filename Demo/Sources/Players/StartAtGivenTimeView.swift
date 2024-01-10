//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxCoreBusiness
import PillarboxPlayer
import SwiftUI

struct StartAtGivenTimeView: View {
    @StateObject private var player = Player(
        item: .urn("urn:rts:video:14608947") { item in
            item.seek(at(.init(value: 1055300, timescale: 1000)))
        }
    )

    var body: some View {
        SystemVideoView(player: player)
            .ignoresSafeArea()
            .onAppear(perform: player.play)
    }
}

extension StartAtGivenTimeView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    StartAtGivenTimeView()
}
