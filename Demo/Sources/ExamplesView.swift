//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-exp
struct ExamplesView: View {
    @StateObject private var model = ExamplesViewModel()

    var body: some View {
        List {
            section(title: "SRG SSR streams (URLs)", medias: model.urlMedias)
            section(title: "SRG SSR streams (URNs)", medias: model.urnMedias)
            if !model.protectedMedias.isEmpty {
                section(title: "Protected streams (URNs)", medias: model.protectedMedias)
            }
            section(title: "Apple streams", medias: model.appleMedias)
            section(title: "Aspect ratios", medias: model.aspectRatioMedias)
            section(title: "Unbuffered streams", medias: model.unbufferedMedias)
            section(title: "Corner cases", medias: model.cornerCaseMedias)
        }
        .animation(.easeIn, value: model.protectedMedias)
        .navigationTitle("Examples")
        .refreshable { await model.refresh() }
    }

    @ViewBuilder
    private func section(title: String, medias: [Media]) -> some View {
        Section(title) {
            ForEach(medias) { media in
                Cell(title: media.title, subtitle: media.description) {
                    PlayerView(media: media)
                }
            }
        }
    }
}

struct ExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExamplesView()
        }
    }
}
