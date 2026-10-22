//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct SignLanguageToggleView: View {
    @StateObject private var model = SignLanguageToggleViewModel()

    var body: some View {
        SystemVideoView(player: model.player)
            .transportBar(content: transportBarContent)
            .ignoresSafeArea()
            .onAppear(perform: model.play)
            .tracked(name: "sign-language-toggle")
    }

    @TransportBarContentBuilder
    private func transportBarContent() -> TransportBarContent {
        Toggle("Sign language", systemImage: model.isSigned ? "hand.raised.fill" : "hand.raised", isOn: $model.isSigned)
    }
}

#Preview {
    SignLanguageToggleView()
}
