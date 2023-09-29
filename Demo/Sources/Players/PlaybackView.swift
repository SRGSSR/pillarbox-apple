//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import Player
import SwiftUI

#if os(iOS)

// Behavior: h-exp, v-exp
private struct MainView: View {
    @ObservedObject var player: Player
    @Binding var layout: PlaybackView.Layout
    @StateObject private var visibilityTracker = VisibilityTracker()

    @State private var layoutInfo: LayoutInfo = .none
    @State private var selectedGravity: AVLayerVideoGravity = .resizeAspect
    @State private var isInteracting = false

    private var areControlsAlwaysVisible: Bool {
        player.isExternalPlaybackActive || player.mediaType == .audio
    }

    var body: some View {
        ZStack {
            main()
            timeBar()
            topBar()
        }
        .statusBarHidden(isFullScreen ? isUserInterfaceHidden : false)
        .animation(.defaultLinear, values: player.isBusy, isUserInterfaceHidden)
        .bind(visibilityTracker, to: player)
        ._debugBodyCounter()
    }

    private var isFullScreen: Bool {
        layout == .inline || layout == .maximized
    }

    private var gravity: AVLayerVideoGravity {
        layoutInfo.isOverCurrentContext ? selectedGravity : .resizeAspect
    }

    private var magnificationGestureMask: GestureMask {
        layoutInfo.isOverCurrentContext ? .all : .subviews
    }

    private var isUserInterfaceHidden: Bool {
        visibilityTracker.isUserInterfaceHidden && !areControlsAlwaysVisible && !player.canReplay()
    }

    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                selectedGravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }

    @ViewBuilder
    private func main() -> some View {
        ZStack {
            video()
            controls()
            loadingIndicator()
        }
        .ignoresSafeArea()
        .animation(.defaultLinear, values: isUserInterfaceHidden, isInteracting)
        .readLayout(into: $layoutInfo)
        .accessibilityAddTraits(.isButton)
        .onTapGesture(perform: visibilityTracker.toggle)
        .gesture(magnificationGesture(), including: magnificationGestureMask)
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in visibilityTracker.reset() }
        )
    }

    @ViewBuilder
    private func timeBar() -> some View {
        TimeBar(player: player, visibilityTracker: visibilityTracker, layout: $layout, isInteracting: $isInteracting)
            .opacity(isUserInterfaceHidden ? 0 : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            CloseButton()
            Spacer()
            VolumeButton(player: player)
        }
        .opacity(isUserInterfaceHidden ? 0 : 1)
        .preventsTouchPropagation()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }

    @ViewBuilder
    private func video() -> some View {
        switch player.mediaType {
        case .audio:
            image(name: "music.note.tv.fill")
        default:
            if player.isExternalPlaybackActive {
                image(name: "tv")
            }
            else {
                VideoView(player: player, gravity: gravity)
            }
        }
    }

    @ViewBuilder
    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.3)
                .opacity(isUserInterfaceHidden || (isInteracting && !areControlsAlwaysVisible) ? 0 : 1)
                .ignoresSafeArea()
            ControlsView(player: player)
                .opacity(isUserInterfaceHidden || isInteracting ? 0 : 1)
        }
    }

    @ViewBuilder
    private func loadingIndicator() -> some View {
        ProgressView()
            .tint(.white)
            .opacity(!player.isBusy || (isInteracting && !areControlsAlwaysVisible) ? 0 : 1)
            .controlSize(.large)
    }

    @ViewBuilder
    private func image(name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // https://www.hackingwithswift.com/quick-start/swiftui/how-to-control-the-tappable-area-of-a-view-using-contentshape
            .contentShape(Rectangle())
            .foregroundColor(.white)
            .padding(60)
    }
}

#endif

private struct ControlsView: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))

    var body: some View {
        HStack(spacing: 30) {
            SkipBackwardButton(player: player, progressTracker: progressTracker)
            PlaybackButton(player: player)
            SkipForwardButton(player: player, progressTracker: progressTracker)
        }
        ._debugBodyCounter(color: .green)
        .animation(.defaultLinear, value: player.playbackState)
        .bind(progressTracker, to: player)
    }
}

// Behavior: h-hug, v-hug
private struct PlaybackMessageView: View {
    let message: String

    var body: some View {
        Text(message)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding()
    }
}

// Behavior: h-hug, v-hug
private struct PlaybackButton: View {
    @ObservedObject var player: Player

    private var imageName: String {
        if player.canReplay() {
            return "arrow.counterclockwise.circle.fill"
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

    var body: some View {
        Button(action: play) {
            Image(systemName: imageName)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: 120, maxHeight: 90)
        .opacity(player.isBusy ? 0 : 1)
        .animation(.defaultLinear, values: player.playbackState, player.canReplay())
    }

    private func play() {
        if player.canReplay() {
            player.replay()
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
        .opacity(player.canSkipBackward() ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipBackward())
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
        .opacity(player.canSkipForward() ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipForward())
    }

    private func skipForward() {
        player.skipForward()
    }
}

// Behavior: h-hug, v-hug
private struct FullScreenButton: View {
    @Binding var layout: PlaybackView.Layout

    var body: some View {
        if let imageName {
            Button(action: toggleFullScreen) {
                Image(systemName: imageName)
                    .resizable()
                    .tint(.white)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }

    private var imageName: String? {
        switch layout {
        case .inline:
            return nil
        case .minimized:
            return "arrow.up.left.and.arrow.down.right"
        case .maximized:
            return "arrow.down.right.and.arrow.up.left"
        }
    }

    private func toggleFullScreen() {
        switch layout {
        case .minimized:
            layout = .maximized
        case .maximized:
            layout = .minimized
        default:
            break
        }
    }
}

// Behavior: h-hug, v-hug
private struct VolumeButton: View {
    @ObservedObject var player: Player

    var body: some View {
        Button(action: toggleMuted) {
            Image(systemName: imageName)
                .tint(.white)
                .frame(width: 45, height: 45)
        }
    }

    private var imageName: String {
        player.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill"
    }

    private func toggleMuted() {
        player.isMuted.toggle()
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

#if os(iOS)

// Behavior: h-exp, v-hug
private struct TimeBar: View {
    @ObservedObject var player: Player
    @ObservedObject var visibilityTracker: VisibilityTracker
    @Binding var layout: PlaybackView.Layout
    @Binding var isInteracting: Bool

    @StateObject private var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    private var prioritizesVideoDevices: Bool {
        player.mediaType == .video
    }

    var body: some View {
        HStack(spacing: 8) {
            routePickerView()
            HStack(spacing: 20) {
                TimeSlider(player: player, progressTracker: progressTracker)
                LiveLabel(player: player, progressTracker: progressTracker)

                Group {
                    settingsMenu()
                    FullScreenButton(layout: $layout)
                }
                .padding(.vertical, 12)
            }
        }
        .frame(height: 44)
        .preventsTouchPropagation()
        .padding(.trailing, 12)
        .onChange(of: progressTracker.isInteracting) { isInteracting = $0 }
        .bind(progressTracker, to: player)
    }

    @ViewBuilder
    private func routePickerView() -> some View {
        if player.configuration.allowsExternalPlayback {
            RoutePickerView(prioritizesVideoDevices: prioritizesVideoDevices)
                .tint(.white)
                .aspectRatio(contentMode: .fit)
        }
    }

    @ViewBuilder
    private func settingsMenu() -> some View {
        Menu {
            player.standardSettingMenu()
        } label: {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .tint(.white)
                .aspectRatio(contentMode: .fit)
        }
        .menuOrder(.fixed)
    }
}

// Behavior: h-exp, v-hug
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
        return Self.formattedTime((time - timeRange.start).seconds, duration: timeRange.duration.seconds)
    }

    private var formattedTotalTime: String? {
        guard player.streamType == .onDemand, let timeRange = progressTracker.timeRange else { return nil }
        return Self.formattedTime(timeRange.duration.seconds, duration: timeRange.duration.seconds)
    }

    private var isVisible: Bool {
        progressTracker.isProgressAvailable && player.streamType != .unknown
    }

    var body: some View {
        PlaybackSlider(
            progressTracker: progressTracker,
            minimumValueLabel: {
                label(withText: formattedElapsedTime)
            },
            maximumValueLabel: {
                label(withText: formattedTotalTime)
            }
        )
        .foregroundColor(.white)
        .tint(.white)
        .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
        .opacity(isVisible ? 1 : 0)
        ._debugBodyCounter(color: .blue)
    }

    private static func formattedTime(_ time: TimeInterval, duration: TimeInterval) -> String {
        if duration < 60 * 60 {
            return shortFormatter.string(from: time)!
        }
        else {
            return longFormatter.string(from: time)!
        }
    }

    @ViewBuilder
    private func label(withText text: String?) -> some View {
        if let text {
            Text(text)
                .font(.caption)
                .monospacedDigit()
                .foregroundColor(.white)
                .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
        }
    }
}

#endif

private struct ErrorView: View {
    let description: String
    @ObservedObject var player: Player

    var body: some View {
        VStack {
            PlaybackButton(player: player)
            PlaybackMessageView(message: description)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topLeading) {
            CloseButton()
        }
    }
}

/// A playback view with standard controls. Requires an ancestor view to own the player to be used.
/// Behavior: h-exp, v-exp
struct PlaybackView: View {
    enum Layout {
        case inline
        case minimized
        case maximized
    }

    @ObservedObject private var player: Player
    @Binding private var layout: Layout

    var body: some View {
        ZStack {
            if let error = player.error {
                ErrorView(description: error.localizedDescription, player: player)
            }
            else if !player.items.isEmpty {
                videoView()
                    .persistentSystemOverlays(.hidden)
            }
            else {
                PlaybackMessageView(message: "No content")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        CloseButton()
                    }
            }
        }
        .background(.black)
        .onAppear {
            player.becomeActive()
            player.play()
        }
    }

    init(player: Player, layout: Binding<Layout> = .constant(.inline)) {
        self.player = player
        _layout = layout
    }

    @ViewBuilder
    private func videoView() -> some View {
        ZStack {
#if os(iOS)
            switch UserDefaults.standard.playerLayout {
            case .custom:
                MainView(player: player, layout: $layout)
            case .system:
                SystemVideoView(player: player)
                    .ignoresSafeArea()
                    .overlay(alignment: .topLeading) {
                        CloseButton()
                            .offset(y: -5)
                    }
            }
#else
            SystemVideoView(player: player)
                .ignoresSafeArea()
#endif
        }
    }
}

#Preview {
    PlaybackView(player: Player(item: Media(from: URLTemplate.onDemandVideoLocalHLS).playerItem()))
}
