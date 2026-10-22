//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SignLanguageToggleView: View {
    @StateObject private var model = SignLanguageToggleViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PlaybackView(player: model.player)
            signLanguageToggle()
        }
        .background(.black)
        .onAppear(perform: model.play)
        .tracked(name: "sign-language-toggle")
    }

    private func signLanguageToggle() -> some View {
        Toggle(isOn: $model.isSigned) {
            Label("Sign language", systemImage: "hand.raised")
        }
        .foregroundStyle(.white)
        .padding()
    }
}

extension SignLanguageToggleView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    SignLanguageToggleView()
}
