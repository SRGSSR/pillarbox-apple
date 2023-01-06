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
private struct ContentView: View {
    @ObservedObject var player: Player
    @State private var isUserInterfaceHidden = false

    var body: some View {
        ZStack {
            Group {
                VideoView(player: player)
                Group {
                    Color(white: 0, opacity: 0.3)
                    PlaybackButton(player: player)
                }
                .opacity(isUserInterfaceHidden ? 0 : 1)

                ProgressView()
                    .tint(Color.white)
                    .opacity(player.isBuffering ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
            }
            .onTapGesture {
                isUserInterfaceHidden.toggle()
            }
            .accessibilityAddTraits(.isButton)
            .ignoresSafeArea()
#if os(iOS)
            TimeBar(player: player)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
#endif
        }
        .animation(.easeInOut(duration: 0.2), value: isUserInterfaceHidden)
        .debugBodyCounter()
    }
}

// Behavior: h-exp, v-exp
private struct MessageView: View {
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
private struct PlaybackButton: View {
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
        Button(action: player.togglePlayPause) {
            Image(systemName: playbackButtonImageName)
                .resizable()
                .tint(.white)
        }
        .opacity(player.isBuffering ? 0 : 1)
        .frame(width: 90, height: 90)
        .debugBodyCounter(color: .green)
    }
}

// Behavior: h-hug, v-hug
private struct LiveLabel: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker

    private var canSkipToLive: Bool {
        player.canSkipToLive(from: progressTracker.time ?? player.time)
    }

    var body: some View {
        if player.streamType == .dvr || player.streamType == .live {
            Button(action: skipToLive) {
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

    private func skipToLive() {
        player.skipToLive()
    }
}

// Behavior: h-exp, v-hug
@available(tvOS, unavailable)
private struct TimeBar: View {
    @ObservedObject var player: Player

    @StateObject private var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    var body: some View {
        HStack(spacing: 0) {
            RoutePickerView()
                .frame(width: 45, height: 45)
            TimeSlider(player: player, progressTracker: progressTracker)
            LiveLabel(player: player, progressTracker: progressTracker)
        }
        .padding(.horizontal, 6)
        .bind(progressTracker, to: player)
    }
}

// Behavior: h-exp, v-hug
@available(tvOS, unavailable)
private struct TimeSlider: View {
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
                Slider(value: .constant(0))
                    .hidden()
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

// Behavior: h-exp, v-exp
struct PlaybackView: View {
    @ObservedObject var player: Player

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
            player.play()
        }
    }
}

// MARK: Preview

struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackView(player: Player())
            .background(.black)
            .previewLayout(.fixed(width: 320, height: 180))
    }
}
