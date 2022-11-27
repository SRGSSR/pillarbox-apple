//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// MARK: View

// Behavior: h-exp, v-exp
struct PlayerView: View {
    let medias: [Media]

    @StateObject private var player = Player()

    var body: some View {
        ZStack {
            if !player.items.isEmpty {
                switch player.playbackState {
                case let .failed(error: error):
                    MessageView(message: error.localizedDescription)
                default:
                    ContentView(player: player)
                }
            }
            else {
                MessageView(message: "No content")
            }
        }
        .background(.black)
        .onAppear {
            play()
        }
    }

    init(medias: [Media]) {
        self.medias = medias
    }

    init(media: Media) {
        self.init(medias: [media])
    }

    private func play() {
        player.items = medias.compactMap(\.playerItem)
        player.play()
    }
}

private extension PlayerView {
    // Behavior: h-exp, v-exp
    struct ContentView: View {
        @ObservedObject var player: Player
        @State private var isUserInterfaceHidden = false

        var body: some View {
            ZStack {
                Group {
                    VideoView(player: player)
                    ControlsView(player: player, isUserInterfaceHidden: isUserInterfaceHidden)
                }
                .onTapGesture {
                    isUserInterfaceHidden.toggle()
                }
                .accessibilityAddTraits(.isButton)
                .ignoresSafeArea()
#if os(iOS)
                TimeBar(player: player, isUserInterfaceHidden: isUserInterfaceHidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
            }
            .animation(.easeInOut(duration: 0.2), value: isUserInterfaceHidden)
        }
    }

    // Behavior: h-exp, v-exp
    struct ControlsView: View {
        @ObservedObject var player: Player
        let isUserInterfaceHidden: Bool

        var body: some View {
            ZStack {
                if !isUserInterfaceHidden {
                    Color(white: 0, opacity: 0.3)
                    HStack(spacing: 40) {
                        PreviousButton(player: player)
                        PlaybackButton(player: player)
                        NextButton(player: player)
                    }
                }
                if player.isBuffering {
                    ProgressView()
                }
            }
            .tint(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
            .debugBodyCounter()
        }
    }

    // Behavior: h-exp, v-exp
    struct MessageView: View {
        let message: String

        var body: some View {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // Behavior: h-hug, v-hug
    struct NextButton: View {
        @ObservedObject var player: Player

        var body: some View {
            Group {
                if player.canAdvanceToNextItem() {
                    Button(action: { player.advanceToNextItem() }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                    }
                }
                else {
                    Color.clear
                }
            }
            .frame(width: 45, height: 45)
        }
    }

    // Behavior: h-hug, v-hug
    struct PlaybackButton: View {
        @ObservedObject var player: Player

        private var playbackButtonImageName: String {
            switch player.playbackState {
            case .playing:
                return "pause.circle.fill"
            default:
                return "play.circle.fill"
            }
        }

        var body: some View {
            Button(action: { player.togglePlayPause() }) {
                Image(systemName: playbackButtonImageName)
                    .resizable()
            }
            .opacity(player.isBuffering ? 0 : 1)
            .frame(width: 90, height: 90)
            .debugBodyCounter(color: .green)
        }
    }

    // Behavior: h-hug, v-hug
    struct PreviousButton: View {
        @ObservedObject var player: Player

        var body: some View {
            Group {
                if player.canReturnToPreviousItem() {
                    Button(action: { player.returnToPreviousItem() }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                    }
                }
                else {
                    Color.clear
                }
            }
            .frame(width: 45, height: 45)
        }
    }

    // Behavior: h-hug, v-hug
    struct LiveLabel: View {
        @ObservedObject var player: Player
        @ObservedObject var progressTracker: ProgressTracker

        private var canSkipToLive: Bool {
            player.canSkipToLive(from: progressTracker.time ?? player.time)
        }

        var body: some View {
            if player.streamType == .dvr || player.streamType == .live {
                Button(action: { player.skipToLive() }) {
                    Text("LIVE")
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(canSkipToLive ? .gray : .red)
                        .cornerRadius(4)
                }
                .disabled(!canSkipToLive)
            }
        }
    }

    // Behavior: h-exp, v-hug
    @available(tvOS, unavailable)
    struct TimeBar: View {
        @ObservedObject var player: Player
        let isUserInterfaceHidden: Bool

        @StateObject private var progressTracker = ProgressTracker(
            interval: CMTime(value: 1, timescale: 10),
            seekBehavior: UserDefaults.standard.seekBehavior
        )

        var body: some View {
            HStack(spacing: 0) {
                TimeSlider(player: player, progressTracker: progressTracker)
                LiveLabel(player: player, progressTracker: progressTracker)
            }
            .opacity(isUserInterfaceHidden ? 0 : 1)
            .padding(.horizontal, 6)
            .bind(progressTracker, to: player)
        }
    }

    // Behavior: h-exp, v-hug
    @available(tvOS, unavailable)
    struct TimeSlider: View {
        private static let blankFormattedTime = "--:--"

        private static let shortFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second, .minute]
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()

        private static let longFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second, .minute, .hour]
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()

        @ObservedObject var player: Player
        @ObservedObject var progressTracker: ProgressTracker

        private var timeRange: CMTimeRange {
            player.timeRange
        }

        private var formattedElapsedTime: String {
            guard timeRange.isValid else { return Self.blankFormattedTime }
            let time = progressTracker.time ?? player.time
            guard time.isValid else { return Self.blankFormattedTime }
            return Self.formattedDuration((time - timeRange.start).seconds)
        }

        private var formattedTotalTime: String {
            guard timeRange.isValid else { return Self.blankFormattedTime }
            return Self.formattedDuration((timeRange.duration).seconds)
        }

        var body: some View {
            Group {
                switch player.streamType {
                case .onDemand:
                    Slider(
                        progressTracker: progressTracker,
                        label: {
                            Text("Progress")
                        },
                        minimumValueLabel: {
                            Text(formattedElapsedTime)
                        },
                        maximumValueLabel: {
                            Text(formattedTotalTime)
                        }
                    )
                case .unknown:
                    // `EmptyView` has h-hug, v-hug behavior.
                    EmptyView()
                        .frame(maxWidth: .infinity)
                default:
                    Slider(progressTracker: progressTracker) {
                        Text("Progress")
                    }
                }
            }
            .foregroundColor(.white)
            .tint(.white)
            .padding()
            .debugBodyCounter(color: .blue)
        }

        private static func formattedDuration(_ duration: TimeInterval) -> String {
            if duration < 60 * 60 {
                return shortFormatter.string(from: duration)!
            }
            else {
                return longFormatter.string(from: duration)!
            }
        }
    }
}

// MARK: Preview

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(media: MediaURL.onDemandVideoLocalHLS)
    }
}
