//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import Player
import SwiftUI

// Behavior: h-exp, v-exp
@available(tvOS, unavailable)
private struct MainView: View {
    @ObservedObject var player: Player
    @StateObject private var visibilityTracker = VisibilityTracker()

    @State private var layoutInfo: LayoutInfo = .none
    @State private var selectedGravity: AVLayerVideoGravity = .resizeAspect

    var body: some View {
        InteractionView(action: visibilityTracker.reset) {
            ZStack {
                main()
                timeBar()
            }
            .animation(.linear(duration: 0.2), value: player.isBusy)
            .animation(.linear(duration: 0.2), value: isUserInterfaceHidden)
        }
        .bind(visibilityTracker, to: player)
        .debugBodyCounter()
    }

    private var gravity: AVLayerVideoGravity {
        layoutInfo.isMaximized ? selectedGravity : .resizeAspect
    }

    private var magnificationGestureMask: GestureMask {
        layoutInfo.isMaximized ? .all : .subviews
    }

    private var isUserInterfaceHidden: Bool {
        visibilityTracker.isUserInterfaceHidden && !player.canRestart()
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                selectedGravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }

    @ViewBuilder
    private func main() -> some View {
        LayoutReader(layoutInfo: $layoutInfo) {
            ZStack {
                video()
                controls()
                loadingIndicator()
            }
            .animation(.linear(duration: 0.2), value: isUserInterfaceHidden)
            .accessibilityAddTraits(.isButton)
            .onTapGesture(perform: visibilityTracker.toggle)
            .gesture(magnificationGesture(), including: magnificationGestureMask)
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func timeBar() -> some View {
        TimeBar(player: player)
            .opacity(isUserInterfaceHidden ? 0 : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func video() -> some View {
        if player.isExternalPlaybackActive {
            Image(systemName: "airplayvideo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
                .contentShape(Rectangle())
                .foregroundColor(.white)
                .padding()
        }
        else {
            VideoView(player: player, gravity: gravity)
        }
    }

    @ViewBuilder
    private func controls() -> some View {
        ControlsView(player: player)
            .opacity(isUserInterfaceHidden ? 0 : 1)
    }

    @ViewBuilder
    private func loadingIndicator() -> some View {
        ProgressView()
            .tint(.white)
            .opacity(player.isBusy ? 1 : 0)
            .controlSize(.large)
    }
}

private struct ControlsView: View {
    @ObservedObject var player: Player
    @StateObject var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))

    var body: some View {
        ZStack {
            Color(white: 0, opacity: 0.3)
            HStack(spacing: 30) {
                SkipBackwardButton(player: player, progressTracker: progressTracker)
                PlaybackButton(player: player)
                SkipForwardButton(player: player, progressTracker: progressTracker)
            }
            .debugBodyCounter(color: .green)
        }
        .animation(.linear(duration: 0.2), value: player.playbackState)
        .bind(progressTracker, to: player)
    }
}

// Behavior: h-exp, v-exp
private struct PlaybackMessageView: View {
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

    private var imageName: String {
        if canRestart {
            return "arrow.counterclockwise"
        }
        else {
            switch player.playbackState {
            case .playing:
                return "pause.circle.fill"
            default:
                return "play.circle.fill"
            }
        }
    }

    private var canRestart: Bool {
        player.canRestart()
    }

    var body: some View {
        Button(action: play) {
            Image(systemName: imageName)
                .resizable()
                .tint(.white)
                .opacity(player.isBusy ? 0 : 1)
                .animation(.linear(duration: 0.2), value: player.playbackState)
                .animation(.linear(duration: 0.2), value: canRestart)
        }
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: 120, maxHeight: 90)
    }

    private func play() {
        if canRestart {
            player.restart()
        }
        else {
            player.togglePlayPause()
        }
    }
}

// Behavior: h-hug, v-hug
private struct SkipBackwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker

    var body: some View {
        Button(action: skipBackward) {
            Image(systemName: "gobackward.10")
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(canSkipBackward ? 1 : 0)
        .animation(.linear(duration: 0.2), value: canSkipBackward)
    }

    private var canSkipBackward: Bool {
        player.canSkipBackward()
    }

    private func skipBackward() {
        player.skipBackward()
    }
}

// Behavior: h-hug, v-hug
private struct SkipForwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker

    var body: some View {
        Button(action: skipForward) {
            Image(systemName: "goforward.10")
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(canSkipForward ? 1 : 0)
        .animation(.linear(duration: 0.2), value: canSkipForward)
    }

    private var canSkipForward: Bool {
        player.canSkipForward()
    }

    private func skipForward() {
        player.skipForward()
    }
}

// Behavior: h-hug, v-hug
private struct LiveLabel: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker

    private var canSkipToLive: Bool {
        player.canSkipToDefault()
    }

    private var liveButtonColor: Color {
        canSkipToLive && player.streamType == .dvr ? .gray : .red
    }

    var body: some View {
        if player.streamType == .dvr || player.streamType == .live {
            Button(action: skipToLive) {
                Text("LIVE")
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(liveButtonColor)
                    .cornerRadius(4)
            }
            .disabled(!canSkipToLive)
        }
    }

    private func skipToLive() {
        player.skipToDefault()
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
            routePickerView()
            TimeSlider(player: player, progressTracker: progressTracker)
            LiveLabel(player: player, progressTracker: progressTracker)
        }
        .padding(.horizontal, 6)
        .bind(progressTracker, to: player)
    }

    @ViewBuilder
    private func routePickerView() -> some View {
        if player.configuration.allowsExternalPlayback {
            RoutePickerView()
                .tint(.white)
                .frame(width: 45, height: 45)
        }
    }
}

// Behavior: h-exp, v-hug
@available(tvOS, unavailable)
private struct TimeSlider: View {
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

    private var formattedElapsedTime: String? {
        guard player.streamType == .onDemand, let time = progressTracker.time, let timeRange = progressTracker.timeRange else {
            return nil
        }
        return Self.formattedDuration((time - timeRange.start).seconds)
    }

    private var formattedTotalTime: String? {
        guard player.streamType == .onDemand, let timeRange = progressTracker.timeRange else { return nil }
        return Self.formattedDuration(timeRange.duration.seconds)
    }

    private var isVisible: Bool {
        progressTracker.isProgressAvailable && player.streamType != .unknown
    }

    var body: some View {
        Slider(
            progressTracker: progressTracker,
            label: {
                Text("Progress")
            },
            minimumValueLabel: {
                label(withText: formattedElapsedTime)
            },
            maximumValueLabel: {
                label(withText: formattedTotalTime)
            }
        )
        .foregroundColor(.white)
        .tint(.white)
        .opacity(isVisible ? 1 : 0)
        .transaction { transaction in
            transaction.animation = nil
        }
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

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .monospacedDigit()
        }
    }
}

/// A playback view with standard controls. Requires an ancestor view to own the player to be used.
/// Behavior: h-exp, v-exp
struct PlaybackView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            if !player.items.isEmpty {
                switch player.playbackState {
                case let .failed(error: error):
                    PlaybackMessageView(message: error.localizedDescription)
                default:
                    videoView()
                }
            }
            else {
                PlaybackMessageView(message: "No content")
            }
        }
        .background(.black)
        .onAppear(perform: player.play)
    }

    @ViewBuilder
    private func videoView() -> some View {
#if os(iOS)
        MainView(player: player)
#else
        VideoView(player: player)
#endif
    }
}

struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackView(player: Player())
            .background(.black)
            .previewLayout(.fixed(width: 320, height: 180))
    }
}
