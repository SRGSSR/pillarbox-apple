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
                Self.section(for: .tvTopics, vendors: [.SRF, .RTS, .RSI, .RTR, .SWI])
                Self.section(for: .tvLatestMedias, vendors: [.SRF, .RTS, .RSI, .RTR, .SWI])
                Self.section(for: .tvLivestreams, vendors: [.SRF, .RTS, .RSI, .RTR])
                Self.section(for: .tvShows, vendors: [.SRF, .RTS, .RSI, .RTR])
                Self.section(for: .liveCenterVideos, vendors: [.SRF, .RTS, .RSI])
                Self.section(for: .tvScheduledLivestreams, vendors: [.SRF, .RTS, .RSI, .RTR])
                Self.section(for: .radioLivestreams, vendors: [.SRF, .RTS, .RSI, .RTR])
                Self.radioShows()
                Self.latestAudiosSection()
            }
            .navigationTitle("Lists")
        }
    }

    @ViewBuilder
    private static func section(title: String, configurations: [ContentListViewModel.Configuration]) -> some View {
        Section(title) {
            ForEach(configurations, id: \.self) { configuration in
                NavigationLink(configuration.name) {
                    ContentListView(configuration: configuration)
                }
            }
        }
    }

    @ViewBuilder
    private static func radioShows() -> some View {
        section(title: "Radio Shows", configurations: [
            .init(kind: .radioShows(radioChannel: .SRF1), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .SRF2Kultur), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .SRF3), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .SRF4News), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .SRFMusikwelle), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .SRFVirus), vendor: .SRF),
            .init(kind: .radioShows(radioChannel: .RTSLaPremiere), vendor: .RTS),
            .init(kind: .radioShows(radioChannel: .RTSEspace2), vendor: .RTS),
            .init(kind: .radioShows(radioChannel: .RTSCouleur3), vendor: .RTS),
            .init(kind: .radioShows(radioChannel: .RTSOptionMusique), vendor: .RTS),
            .init(kind: .radioShows(radioChannel: .RTSPodcastsOriginaux), vendor: .RTS),
            .init(kind: .radioShows(radioChannel: .RSIReteUno), vendor: .RSI),
            .init(kind: .radioShows(radioChannel: .RSIReteDue), vendor: .RSI),
            .init(kind: .radioShows(radioChannel: .RSIReteTre), vendor: .RSI),
            .init(kind: .radioShows(radioChannel: .RTR), vendor: .RTR)
        ])
    }

    @ViewBuilder
    private static func latestAudiosSection() -> some View {
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

    @ViewBuilder
    private static func section(for kind: ContentListViewModel.Kind, vendors: [SRGVendor]) -> some View {
        let configurations = vendors.map { vendor in
            ContentListViewModel.Configuration(kind: kind, vendor: vendor)
        }
        section(title: kind.name, configurations: configurations)
    }
}
