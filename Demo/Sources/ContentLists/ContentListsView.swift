//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

// Behavior: h-exp, v-exp
struct ContentListsView: View {
    @AppStorage(UserDefaults.serverSettingKey)
    private var selectedServerSetting: ServerSetting = .production

    var body: some View {
        List {
            Self.section(for: .tvTopics, image: "tv", vendors: [.RSI, .RTR, .RTS, .SRF, .SWI])
            Self.section(for: .tvLatestMedias, image: "play.tv", vendors: [.RSI, .RTR, .RTS, .SRF, .SWI])
            Self.section(for: .tvLivestreams, image: "livephoto.play", vendors: [.RSI, .RTR, .RTS, .SRF])
            Self.section(for: .tvShows, image: "rectangle.on.rectangle.angled", vendors: [.RSI, .RTR, .RTS, .SRF])
            Self.section(for: .liveCenterVideos, image: "sportscourt", vendors: [.RSI, .RTS, .SRF])
            Self.section(for: .tvScheduledLivestreams, image: "globe", vendors: [.RSI, .RTR, .RTS, .SRF])
            Self.section(for: .radioLivestreams, image: "antenna.radiowaves.left.and.right", vendors: [.RSI, .RTR, .RTS, .SRF])
            Self.radioShows(image: "waveform")
            Self.latestAudiosSection(image: "music.note.list")
        }
        .tracked(name: "lists")
#if os(iOS)
        .navigationTitle("Lists (\(selectedServerSetting.title))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarTitleMenu {
            serverSettingsMenu()
        }
#endif
    }

    @ViewBuilder
    private static func section(for list: ContentList, image: String? = nil, vendors: [SRGVendor]) -> some View {
        let configurations = vendors.map { vendor in
            ContentList.Configuration(list: list, vendor: vendor)
        }
        section(title: list.name, image: image, configurations: configurations)
    }

    @ViewBuilder
    private static func section(title: String, image: String? = nil, configurations: [ContentList.Configuration]) -> some View {
        Section {
            ForEach(configurations) { configuration in
                NavigationLink(configuration.name, destination: .contentList(configuration: configuration))
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
            .init(list: .radioShows(radioChannel: .RSIReteUno), vendor: .RSI),
            .init(list: .radioShows(radioChannel: .RSIReteDue), vendor: .RSI),
            .init(list: .radioShows(radioChannel: .RSIReteTre), vendor: .RSI),
            .init(list: .radioShows(radioChannel: .RTR), vendor: .RTR),
            .init(list: .radioShows(radioChannel: .RTSLaPremiere), vendor: .RTS),
            .init(list: .radioShows(radioChannel: .RTSEspace2), vendor: .RTS),
            .init(list: .radioShows(radioChannel: .RTSCouleur3), vendor: .RTS),
            .init(list: .radioShows(radioChannel: .RTSOptionMusique), vendor: .RTS),
            .init(list: .radioShows(radioChannel: .RTSPodcastsOriginaux), vendor: .RTS),
            .init(list: .radioShows(radioChannel: .SRF1), vendor: .SRF),
            .init(list: .radioShows(radioChannel: .SRF2Kultur), vendor: .SRF),
            .init(list: .radioShows(radioChannel: .SRF3), vendor: .SRF),
            .init(list: .radioShows(radioChannel: .SRF4News), vendor: .SRF),
            .init(list: .radioShows(radioChannel: .SRFMusikwelle), vendor: .SRF),
            .init(list: .radioShows(radioChannel: .SRFVirus), vendor: .SRF)
        ])
    }

    @ViewBuilder
    private static func latestAudiosSection(image: String) -> some View {
        section(title: "Latest Audios", image: image, configurations: [
            .init(list: .radioLatestMedias(radioChannel: .RSIReteUno), vendor: .RSI),
            .init(list: .radioLatestMedias(radioChannel: .RSIReteDue), vendor: .RSI),
            .init(list: .radioLatestMedias(radioChannel: .RSIReteTre), vendor: .RSI),
            .init(list: .radioLatestMedias(radioChannel: .RTR), vendor: .RTR),
            .init(list: .radioLatestMedias(radioChannel: .RTSLaPremiere), vendor: .RTS),
            .init(list: .radioLatestMedias(radioChannel: .RTSEspace2), vendor: .RTS),
            .init(list: .radioLatestMedias(radioChannel: .RTSCouleur3), vendor: .RTS),
            .init(list: .radioLatestMedias(radioChannel: .RTSOptionMusique), vendor: .RTS),
            .init(list: .radioLatestMedias(radioChannel: .RTSPodcastsOriginaux), vendor: .RTS),
            .init(list: .radioLatestMedias(radioChannel: .SRF1), vendor: .SRF),
            .init(list: .radioLatestMedias(radioChannel: .SRF2Kultur), vendor: .SRF),
            .init(list: .radioLatestMedias(radioChannel: .SRF3), vendor: .SRF),
            .init(list: .radioLatestMedias(radioChannel: .SRF4News), vendor: .SRF),
            .init(list: .radioLatestMedias(radioChannel: .SRFMusikwelle), vendor: .SRF),
            .init(list: .radioLatestMedias(radioChannel: .SRFVirus), vendor: .SRF)
        ])
    }

#if os(iOS)
    @ViewBuilder
    private func serverSettingsMenu() -> some View {
        Menu {
            Picker("Server", selection: $selectedServerSetting) {
                ForEach(ServerSetting.allCases, id: \.self) { service in
                    Text(service.title).tag(service)
                }
            }
        } label: {
            Label("Server", systemImage: "server.rack")
        }
        .pickerStyle(.inline)
    }
#endif
}

#Preview {
    NavigationStack {
        ContentListsView()
    }
    .environmentObject(Router())
}
