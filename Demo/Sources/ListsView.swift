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
                tvTopicSection()
                latestVideosSection()
                liveTvSection()
                liveCenterSection()
                liveWebSection()
                liveRadioSection()
                latestAudiosSection()
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

    @ViewBuilder
    private func tvTopicSection() -> some View {
        section(title: "Topics TV", configurations: [
            .init(kind: .tvTopics, vendor: .SRF),
            .init(kind: .tvTopics, vendor: .RTS),
            .init(kind: .tvTopics, vendor: .RSI),
            .init(kind: .tvTopics, vendor: .RTR),
            .init(kind: .tvTopics, vendor: .SWI)
        ])
    }

    @ViewBuilder
    private func latestVideosSection() -> some View {
        section(title: "Latest Videos", configurations: [
            .init(kind: .tvLatestMedias, vendor: .SRF),
            .init(kind: .tvLatestMedias, vendor: .RTS),
            .init(kind: .tvLatestMedias, vendor: .RSI),
            .init(kind: .tvLatestMedias, vendor: .RTR),
            .init(kind: .tvLatestMedias, vendor: .SWI)
        ])
    }

    @ViewBuilder
    private func liveTvSection() -> some View {
        section(title: "Live TV", configurations: [
            .init(kind: .tvLivestreams, vendor: .SRF),
            .init(kind: .tvLivestreams, vendor: .RTS),
            .init(kind: .tvLivestreams, vendor: .RSI),
            .init(kind: .tvLivestreams, vendor: .RTR)
        ])
    }

    @ViewBuilder
    private func liveCenterSection() -> some View {
        section(title: "Live Center", configurations: [
            .init(kind: .liveCenterVideos, vendor: .SRF),
            .init(kind: .liveCenterVideos, vendor: .RTS),
            .init(kind: .liveCenterVideos, vendor: .RSI)
        ])
    }

    @ViewBuilder
    private func liveWebSection() -> some View {
        section(title: "Live Web", configurations: [
            .init(kind: .tvScheduledLivestreams, vendor: .SRF),
            .init(kind: .tvScheduledLivestreams, vendor: .RTS),
            .init(kind: .tvScheduledLivestreams, vendor: .RSI),
            .init(kind: .tvScheduledLivestreams, vendor: .RTR)
        ])
    }

    @ViewBuilder
    private func liveRadioSection() -> some View {
        section(title: "Live Radio", configurations: [
            .init(kind: .radioLivestreams, vendor: .SRF),
            .init(kind: .radioLivestreams, vendor: .RTS),
            .init(kind: .radioLivestreams, vendor: .RSI),
            .init(kind: .radioLivestreams, vendor: .RTR)
        ])
    }

    @ViewBuilder
    private func latestAudiosSection() -> some View {
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
}
