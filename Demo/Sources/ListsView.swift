//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

// Behavior: h-exp, v-exp
struct ListsView: View {
    @AppStorage(UserDefaults.serviceUrlEnvironmentKey)
    private var serviceUrl: ServiceUrl = .production

    var body: some View {
        List {
            Self.section(for: .tvTopics, image: "tv", vendors: [.SRF, .RTS, .RSI, .RTR, .SWI])
            Self.section(for: .tvLatestMedias, image: "play.tv", vendors: [.SRF, .RTS, .RSI, .RTR, .SWI])
            Self.section(for: .tvLivestreams, image: "livephoto.play", vendors: [.SRF, .RTS, .RSI, .RTR])
            Self.section(for: .tvShows, image: "rectangle.on.rectangle.angled", vendors: [.SRF, .RTS, .RSI, .RTR])
            Self.section(for: .liveCenterVideos, image: "sportscourt", vendors: [.SRF, .RTS, .RSI])
            Self.section(for: .tvScheduledLivestreams, image: "globe", vendors: [.SRF, .RTS, .RSI, .RTR])
            Self.section(for: .radioLivestreams, image: "antenna.radiowaves.left.and.right", vendors: [.SRF, .RTS, .RSI, .RTR])
            Self.radioShows(image: "waveform")
            Self.latestAudiosSection(image: "music.note.list")
        }
        .navigationTitle("Lists")
        .toolbarTitleMenu {
            titlesMenu()
        }
    }

    @ViewBuilder
    private static func section(for kind: ContentListViewModel.Kind, image: String? = nil, vendors: [SRGVendor]) -> some View {
        let configurations = vendors.map { vendor in
            ContentListViewModel.Configuration(kind: kind, vendor: vendor)
        }
        section(title: kind.name, image: image, configurations: configurations)
    }

    @ViewBuilder
    private static func section(title: String, image: String? = nil, configurations: [ContentListViewModel.Configuration]) -> some View {
        Section {
            ForEach(configurations, id: \.self) { configuration in
                NavigationLink(configuration.name) {
                    ContentListView(configuration: configuration)
                }
            }
        } header: {
            HStack {
                if let image {
                    Image(systemName: image)
                }
                Text(title)
            }
        }
    }

    @ViewBuilder
    private static func radioShows(image: String) -> some View {
        section(title: "Radio Shows", image: image, configurations: [
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
    private static func latestAudiosSection(image: String) -> some View {
        section(title: "Latest Audios", image: image, configurations: [
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
    private func titlesMenu() -> some View {
        ForEach(ServiceUrl.allCases, id: \.self) { service in
            Button {
                serviceUrl = service
            } label: {
                HStack {
                    Text(service.title)
                    if serviceUrl == service {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
    }
}
