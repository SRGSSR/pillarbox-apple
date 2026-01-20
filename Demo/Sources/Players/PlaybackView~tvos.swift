//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct PlaybackView: View {
    @ObservedObject var player: Player
    private var infoViewTabsContent: (() -> InfoViewTabsContent)?

    var body: some View {
        if let error = player.error {
            ErrorView(error: error, player: player)
        }
        else if !player.items.isEmpty {
            MainView(player: player, infoViewTabsContent: infoViewTabsContent)
        }
        else {
            UnavailableView {
                Text("No content")
            }
            .foregroundStyle(.white)
        }
    }

    init(player: Player) {
        self.player = player
    }
}

private struct MainView: View {
    @AppStorage(UserDefaults.DemoSettingKey.qualitySetting.rawValue)
    private var qualitySetting: QualitySetting = .high

    @State private var streamType: StreamType = .unknown
    @StateObject private var progressTracker = ProgressTracker(interval: .init(value: 1, timescale: 1))
    @ObservedObject var player: Player
    let infoViewTabsContent: (() -> InfoViewTabsContent)?

    private var skipInfoViewActionTitle: LocalizedStringResource {
        streamType == .onDemand ? "From Beginning" : "Back to Live"
    }

    private var skipInfoViewActionSystemImage: String {
        streamType == .onDemand ? "play.fill" : "forward.end.fill"
    }

    var body: some View {
        ZStack {
            if let infoViewTabsContent {
                systemVideoView()
                    .infoViewTabs(content: infoViewTabsContent)
            }
            else {
                systemVideoView()
            }
        }
        .ignoresSafeArea()
        .onReceive(player: player, assign: \.streamType, to: $streamType)
        .bind(progressTracker, to: player)
    }

    init(player: Player, infoViewTabsContent: (() -> InfoViewTabsContent)?) {
        self.player = player
        self.infoViewTabsContent = infoViewTabsContent
    }

    private func systemVideoView() -> SystemVideoView<EmptyView> {
        SystemVideoView(player: player)
            .supportsPictureInPicture()
            .transportBar(content: transportBarContent)
            .contextualActions(content: contextualActionsContent)
            .infoViewActions(content: infoViewActionsContent)
    }

    @TransportBarContentBuilder
    private func transportBarContent() -> TransportBarContent {
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
    private func contextualActionsContent() -> ContextualActionsContent {
        if let skippableTimeRange = player.skippableTimeRange(at: progressTracker.time) {
            Button("Skip") {
                player.seek(to: skippableTimeRange.end)
            }
        }
    }

    @InfoViewActionsContentBuilder
    private func infoViewActionsContent() -> InfoViewActionsContent {
        if player.canSkipToDefault() {
            Button(skipInfoViewActionTitle, systemImage: skipInfoViewActionSystemImage) {
                player.skipToDefault()
            }
        }
    }
}

extension PlaybackView {
    func infoViewTabs(@InfoViewTabsContentBuilder content: @escaping () -> InfoViewTabsContent) -> Self {
        var view = self
        view.infoViewTabsContent = content
        return view
    }
}

#Preview {
    PlaybackView(player: Player(item: URLMedia.appleBasic_4_3_HLS.item()))
}
