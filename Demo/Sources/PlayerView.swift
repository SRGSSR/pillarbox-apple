//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

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
                .ignoresSafeArea()
    #if os(iOS)
                HStack {
                    SliderView(player: player)
                    LiveLabel(player: player)
                }
                .opacity(isUserInterfaceHidden ? 0 : 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    #endif
            }
            .animation(.easeInOut(duration: 0.2), value: isUserInterfaceHidden)
        }
    }

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
            .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
        }
    }

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
        }
    }

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

    struct LiveLabel: View {
        @ObservedObject var player: Player

        var body: some View {
            if player.streamType == .dvr || player.streamType == .live {
                Button(action: { player.skipToLive() }) {
                    Text("LIVE")
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(player.canSkipToLive() ? .gray : .red)
                        .cornerRadius(4)
                }
                .disabled(!player.canSkipToLive())
            }
        }
    }

    @available(tvOS, unavailable)
    struct SliderView: View {
        private static let blankTime = "--:--"

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

        private var formattedElapsedTime: String {
            guard let time = player.time, let timeRange = player.timeRange else { return Self.blankTime }
            return Self.formattedDuration(CMTimeGetSeconds(time - timeRange.start))
        }

        private var formattedTotalTime: String {
            guard let timeRange = player.timeRange else { return Self.blankTime }
            return Self.formattedDuration(CMTimeGetSeconds(timeRange.duration))
        }

        var body: some View {
            Group {
                switch player.streamType {
                case .onDemand:
                    Slider(
                        player: player,
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
                    EmptyView()
                default:
                    Slider(player: player, label: {
                        Text("Progress")
                    })
                }
            }
            .foregroundColor(.white)
            .tint(.white)
            .padding()
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
