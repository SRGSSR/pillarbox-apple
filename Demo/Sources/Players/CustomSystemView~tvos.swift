//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

/*
private struct _PlaylistView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var player: Player
    @ObservedObject var viewModel: PlaylistViewModel

    var body: some View {
        List(Array(zip(player.items, viewModel.entries)), id: \.0) { item, entry in
            Button {
                player.currentItem = item
            } label: {
                Text(entry.media.title)
                    .bold(item == player.currentItem)
                    .foregroundStyle(item == player.currentItem ? Color.primary : Color.secondary)
            }
        }
    }
}
 */

struct CustomSystemView: View {
    let media: Media
    @StateObject private var model = PlayerViewModel.persisted ?? PlayerViewModel()
    private var supportsPictureInPicture = false

    var body: some View {
        MainView(player: model.player, supportsPictureInPicture: supportsPictureInPicture)
            .enabledForInAppPictureInPicture(persisting: model)
            .background(.black)
            .onAppear(perform: play)
            .tracked(name: "player")
    }

    init(media: Media) {
        self.media = media
    }

    private func play() {
        model.media = media
        model.play()
    }
}

private struct MainView: View {
    @ObservedObject var player: Player
    let supportsPictureInPicture: Bool

    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))
    @State private var streamType: StreamType = .unknown

    @AppStorage(UserDefaults.DemoSettingKey.qualitySetting.rawValue)
    private var qualitySetting: QualitySetting = .high

    private var skipInfoViewActionTitle: LocalizedStringResource {
        streamType == .onDemand ? "From Beginning" : "Back to Live"
    }

    private var skipInfoViewActionSystemImage: String {
        streamType == .onDemand ? "play.fill" : "forward.end.fill"
    }

    var body: some View {
        if let error = player.error {
            ErrorView(error: error, player: player)
        }
        else if !player.items.isEmpty {
            SystemVideoView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
                .transportBar(content: transportBarContent)
                .contextualActions(content: contextualActionsContent)
                .infoViewActions(content: infoViewActionsContent)
                .ignoresSafeArea()
                .onReceive(player: player, assign: \.streamType, to: $streamType)
        }
        else {
            UnavailableView {
                Text("No content")
            }
            .foregroundStyle(.white)
        }
    }

    @TransportBarContentBuilder
    func transportBarContent() -> TransportBarContent {
        Picker("Playback Speed", systemImage: "speedometer", selection: $player.playbackSpeed) {
            for speed in [0.5, 1, 1.25, 1.5, 2] as [Float] {
                Option("\(speed, specifier: "%g×")", value: speed)
            }
        }
        Picker("Quality", systemImage: "person.and.background.dotted", selection: $qualitySetting) {
            for quality in QualitySetting.allCases {
                Option(quality.name, value: quality)
            }
        }
    }

    @ContextualActionsContentBuilder
    func contextualActionsContent() -> ContextualActionsContent {
        if let skippableTimeRange = player.skippableTimeRange(at: progressTracker.time) {
            Button("Skip") {
                player.seek(to: skippableTimeRange.end)
            }
        }
    }

    @InfoViewActionsContentBuilder
    func infoViewActionsContent() -> InfoViewActionsContent {
        if player.canSkipToDefault() {
            Button(skipInfoViewActionTitle, systemImage: skipInfoViewActionSystemImage) {
                player.skipToDefault()
            }
        }
    }
/*
    @InfoViewTabsContentBuilder
    func customInfoViewsContent() -> InfoViewTabsContent {
        if player.items.count > 1 {
            Tab(title: "Playlist") {
                _PlaylistView(player: player, viewModel: viewModel)
                    .frame(height: 400)
            }
        }
    }
 */
}
