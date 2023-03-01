//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

struct ListsView: View {
    var body: some View {
        NavigationStack {
            List {
                section(title: "Latest Videos", configurations: [
                    .init(kind: .tvLatestMedias, vendor: .SRF),
                    .init(kind: .tvLatestMedias, vendor: .RTS),
                    .init(kind: .tvLatestMedias, vendor: .RSI),
                    .init(kind: .tvLatestMedias, vendor: .RTR),
                    .init(kind: .tvLatestMedias, vendor: .SWI)
                ])
                section(title: "Latest Audios", configurations: [
                    .init(kind: .radioLatestMedias(radioChannel: .SRF1), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .SRF2Kultur), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .SRF3), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .SRF4News), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .SRFMusikwelle), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .SRFVirus), vendor: .SRF),
                    .init(kind: .radioLatestMedias(radioChannel: .RTSLaPremiere), vendor: .RTS),
                    .init(kind: .radioLatestMedias(radioChannel: .RTSEspace2), vendor: .RTS),
                    .init(kind: .radioLatestMedias(radioChannel: .RTSCouleur3), vendor: .RTS),
                    .init(kind: .radioLatestMedias(radioChannel: .RTSOptionMusique), vendor: .RTS),
                    .init(kind: .radioLatestMedias(radioChannel: .RTSPodcastsOriginaux), vendor: .RTS),
                    .init(kind: .radioLatestMedias(radioChannel: .RSIReteUno), vendor: .RSI),
                    .init(kind: .radioLatestMedias(radioChannel: .RSIReteDue), vendor: .RSI),
                    .init(kind: .radioLatestMedias(radioChannel: .RSIReteTre), vendor: .RSI),
                    .init(kind: .radioLatestMedias(radioChannel: .RTR), vendor: .RTR)
                ])
            }
            .navigationTitle("Lists")
        }
    }

    @ViewBuilder
    private func section(title: String, configurations: [MediaListViewModel.Configuration]) -> some View {
        Section(title) {
            ForEach(configurations, id: \.self) { configuration in
                NavigationLink(configuration.name) {
                    MediaListView(configuration: configuration)
                }
            }
        }
    }
}

