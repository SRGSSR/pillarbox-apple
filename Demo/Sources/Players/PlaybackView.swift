//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import PillarboxPlayer
import SwiftUI

#if os(iOS)

// Behavior: h-exp, v-exp
private struct MainView: View {
    @ObservedObject var player: Player
    @Binding var layout: PlaybackView.Layout
    let isMonoscopic: Bool
    let supportsPictureInPicture: Bool

    @StateObject private var visibilityTracker = VisibilityTracker()

    @State private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))
    @State private var layoutInfo: LayoutInfo = .none
    @State private var selectedGravity: AVLayerVideoGravity = .resizeAspect
    @State private var isInteracting = false

    private var areControlsAlwaysVisible: Bool {
        player.isExternalPlaybackActive || player.mediaType == .audio
    }

    private var prioritizesVideoDevices: Bool {
        player.mediaType == .video
    }

    var body: some View {
        ZStack {
            main()
            bottomBar()
            topBar()
        }
        .statusBarHidden(isFullScreen ? isUserInterfaceHidden : false)
        .animation(.defaultLinear, value: isUserInterfaceHidden)
        .bind(visibilityTracker, to: player)
        .bind(progressTracker, to: player)
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

    private var title: String? {
        player.metadata.title
    }

    private var subtitle: String? {
        player.metadata.subtitle
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
        .supportsHighSpeed(!isMonoscopic, for: player)
    }

    @ViewBuilder
    private func metadata() -> some View {
        VStack(alignment: .leading) {
            HStack {
                LiveLabel(player: player, progressTracker: progressTracker)
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                }
            }
            if let title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .opacity(isInteracting ? 0 : 1)
    }

    @ViewBuilder
    private func bottomBar() -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {
                metadata()
                if isFullScreen {
                    bottomButtons()
                }
            }
            HStack(spacing: 20) {
                TimeBar(player: player, visibilityTracker: visibilityTracker, isInteracting: $isInteracting)
                if !isFullScreen {
                    bottomButtons()
                }
            }
        }
        .preventsTouchPropagation()
        .opacity(isUserInterfaceHidden ? 0 : 1)
        .animation(.linear(duration: 0.2), values: isUserInterfaceHidden, isInteracting)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func bottomButtons() -> some View {
        HStack(spacing: 20) {
            LiveButton(player: player, progressTracker: progressTracker)
            settingsMenu()
            FullScreenButton(layout: $layout)
        }
    }

    @ViewBuilder
    private func topBar() -> some View {
        HStack {
            HStack(spacing: 20) {
                CloseButton()
                PiPButton()
                routePickerView()
            }
            Spacer()
            HStack(spacing: 20) {
                LoadingIndicator(player: player)
                VolumeButton(player: player)
            }
        }
        .opacity(isUserInterfaceHidden ? 0 : 1)
        .topBarStyle()
        .preventsTouchPropagation()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func routePickerView() -> some View {
        RoutePickerView(prioritizesVideoDevices: prioritizesVideoDevices)
            .tint(.white)
            .aspectRatio(contentMode: .fit)
            .frame(width: 20)
    }

    @ViewBuilder
    private func settingsMenu() -> some View {
        Menu {
            player.standardSettingMenu()
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.white)
        }
        .menuOrder(.fixed)
    }

    @ViewBuilder
    private func video() -> some View {
        ZStack {
            if player.mediaType == .audio {
                image(name: "music.note.tv.fill")
            }
            else if player.isExternalPlaybackActive {
                image(name: "tv")
            }
            else if isMonoscopic {
                MonoscopicVideoView(player: player)
            }
            else {
                VideoView(player: player)
                    .gravity(gravity)
                    .supportsPictureInPicture(supportsPictureInPicture)
            }
        }
        .animation(.easeIn(duration: 0.2), values: player.mediaType, player.isExternalPlaybackActive)
    }

    @ViewBuilder
    private func controls() -> some View {
        ZStack {
            Color(white: 0, opacity: 0.3)
                .opacity(isUserInterfaceHidden || (isInteracting && !areControlsAlwaysVisible) ? 0 : 1)
                .ignoresSafeArea()
            ControlsView(player: player, progressTracker: progressTracker)
                .opacity(isUserInterfaceHidden || isInteracting ? 0 : 1)
        }
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

private struct ControlsView: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker

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
                    .tint(.white)
                    .font(.system(size: 20))
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
                .font(.system(size: 20))
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
private struct LoadingIndicator: View {
    let player: Player

    @State private var isBuffering = false

    var body: some View {
        ProgressView()
            .tint(.white)
            .opacity(isBuffering ? 1 : 0)
            .animation(.linear(duration: 0.1), value: isBuffering)
            .onReceive(player: player, assign: \.isBuffering, to: $isBuffering)
    }
}

// Behavior: h-hug, v-hug
private struct LiveLabel: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @State private var streamType: StreamType = .unknown

    private var canSkipToLive: Bool {
        player.canSkipToDefault()
    }

    private var liveButtonColor: Color {
        canSkipToLive && streamType == .dvr ? .gray : .red
    }

    var body: some View {
        Group {
            if streamType == .dvr || streamType == .live {
                Text("LIVE")
                    .font(.footnote)
                    .padding(.horizontal, 7)
                    .background(liveButtonColor)
                    .foregroundColor(.white)
                    .clipShape(.capsule)
            }
        }
        .onReceive(player: player, assign: \.streamType, to: $streamType)
    }
}
// Behavior: h-hug, v-hug
private struct LiveButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @State private var streamType: StreamType = .unknown

    private var canSkipToLive: Bool {
        streamType == .dvr && player.canSkipToDefault()
    }

    var body: some View {
        Group {
            if canSkipToLive {
                Button(action: skipToLive) {
                    Image(systemName: "forward.end.fill")
                        .foregroundStyle(.white)
                        .fontWeight(.ultraLight)
                        .font(.system(size: 20))
                }
            }
        }
        .onReceive(player: player, assign: \.streamType, to: $streamType)
    }

    private func skipToLive() {
        player.skipToDefault()
    }
}

// Behavior: h-exp, v-hug
private struct TimeBar: View {
    @ObservedObject var player: Player
    @ObservedObject var visibilityTracker: VisibilityTracker
    @Binding var isInteracting: Bool

    @StateObject private var progressTracker = ProgressTracker(
        interval: CMTime(value: 1, timescale: 10),
        seekBehavior: UserDefaults.standard.seekBehavior
    )

    var body: some View {
        TimeSlider(player: player, progressTracker: progressTracker, visibilityTracker: visibilityTracker)
            .onChange(of: progressTracker.isInteracting) { isInteracting = $0 }
            .bind(progressTracker, to: player)
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
    @ObservedObject var visibilityTracker: VisibilityTracker
    @State private var streamType: StreamType = .unknown

    private var formattedElapsedTime: String? {
        guard streamType == .onDemand else { return nil }
        return Self.formattedTime((progressTracker.time - progressTracker.timeRange.start).seconds, duration: progressTracker.timeRange.duration.seconds)
    }

    private var formattedTotalTime: String? {
        guard streamType == .onDemand else { return nil }
        return Self.formattedTime(progressTracker.timeRange.duration.seconds, duration: progressTracker.timeRange.duration.seconds)
    }

    private var isVisible: Bool {
        progressTracker.isProgressAvailable && streamType != .unknown
    }

    var body: some View {
        PlaybackSlider(
            progressTracker: progressTracker,
            minimumValueLabel: {
                label(withText: formattedElapsedTime)
            },
            maximumValueLabel: {
                label(withText: formattedTotalTime)
            },
            onDragging: {
                if UserDefaults.standard.seekBehavior == .deferred {
                    visibilityTracker.reset()
                }
            }
        )
        .foregroundColor(.white)
        .tint(.white)
        .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
        .opacity(isVisible ? 1 : 0)
        ._debugBodyCounter(color: .blue)
        .onReceive(player: player, assign: \.streamType, to: $streamType)
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

    private var imageName: String? {
        if player.canReplay() {
            return "arrow.counterclockwise.circle.fill"
        }
        else if player.shouldPlay {
            return "pause.circle.fill"
        }
        else {
            return "play.circle.fill"
        }
    }

    var body: some View {
        Button(action: play) {
            if let imageName {
                Image(systemName: imageName)
                    .resizable()
                    .tint(.white)
            }
            else {
                Color.clear
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(minWidth: 120, maxHeight: 90)
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
                .topBarStyle()
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

    private var isMonoscopic = false
    private var supportsPictureInPicture = false

    var body: some View {
        ZStack {
            if let error = player.error {
                ErrorView(description: error.localizedDescription, player: player)
            }
            else if !player.items.isEmpty {
                mainView()
                    .persistentSystemOverlays(.hidden)
            }
            else {
                PlaybackMessageView(message: "No content")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .topLeading) {
                        CloseButton()
                            .topBarStyle()
                    }
            }
        }
        .background(.black)
    }

    init(player: Player, layout: Binding<Layout> = .constant(.inline)) {
        self.player = player
        _layout = layout
    }

    @ViewBuilder
    private func mainView() -> some View {
        ZStack {
#if os(iOS)
            MainView(
                player: player,
                layout: $layout,
                isMonoscopic: isMonoscopic,
                supportsPictureInPicture: supportsPictureInPicture
            )
#else
            if isMonoscopic {
                VideoView(player: player)
                    .viewport(.monoscopic(orientation: .monoscopicDefault))
                    .ignoresSafeArea()
            }
            else {
                SystemVideoView(player: player)
                    .supportsPictureInPicture(supportsPictureInPicture)
                    .ignoresSafeArea()
            }
#endif
        }
    }
}

extension PlaybackView {
    func monoscopic(_ isMonoscopic: Bool = true) -> PlaybackView {
        var view = self
        view.isMonoscopic = isMonoscopic
        return view
    }

    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> PlaybackView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}

private extension View {
    func topBarStyle() -> some View {
        padding(.horizontal)
            .frame(minHeight: 35)
    }
}

#Preview {
    PlaybackView(player: Player(item: Media(from: URLTemplate.onDemandVideoLocalHLS).playerItem()))
}
