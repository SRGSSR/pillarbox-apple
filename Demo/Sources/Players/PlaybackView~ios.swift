//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import PillarboxCoreBusiness
import PillarboxMonitoring
import PillarboxPlayer
import SwiftUI

struct PlaybackView: View {
    @ObservedObject private var player: Player
    @Binding private var layout: PlaybackViewLayout

    private var supportsPictureInPicture = false

    var body: some View {
        ZStack {
            if let error = player.error {
                ErrorView(error: error, player: player)
            }
            else if !player.items.isEmpty {
                mainView()
                    .persistentSystemOverlays(.hidden)
            }
            else {
                UnavailableView {
                    Text("No content")
                }
                .foregroundStyle(.white)
                .overlay(alignment: .topLeading) {
                    CloseButton(topBarStyle: true)
                }
            }
        }
        .background(.black)
    }

    init(player: Player, layout: Binding<PlaybackViewLayout> = .constant(.inline)) {
        self.player = player
        _layout = layout
    }

    private func mainView() -> some View {
        MainView(
            player: player,
            layout: $layout,
            supportsPictureInPicture: supportsPictureInPicture
        )
        ._debugBodyCounter()
    }
}

private struct MainView: View {
    @ObservedObject var player: Player
    @Binding var layout: PlaybackViewLayout
    let supportsPictureInPicture: Bool
    @State private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))

    @StateObject private var visibilityTracker = VisibilityTracker()
    @State private var metricsCollector = MetricsCollector(interval: .init(value: 1, timescale: 1), limit: 90)
    @StateObject private var skipTracker = SkipTracker()

    @State private var layoutInfo: LayoutInfo = .none
    @State private var isPresentingMetrics = false
    @State private var selectedGravity: AVLayerVideoGravity = .resizeAspect
    @State private var isInteracting = false

    @AppStorage(UserDefaults.DemoSettingKey.seekBehaviorSetting.rawValue)
    private var seekBehaviorSetting: SeekBehaviorSetting = .optimal

    private var prioritizesVideoDevices: Bool {
        player.mediaType == .video
    }

    private var shouldHideInterface: Bool {
        !shouldKeepControlsAlwaysVisible &&
            (isUserInterfaceHidden || (isInteracting && seekBehaviorSetting == .optimal) || skipTracker.isSkipping)
    }

    private var shouldKeepControlsAlwaysVisible: Bool {
        player.isExternalPlaybackActive || player.mediaType != .video
    }

    private var isToggleGestureEnabled: Bool {
        !isInteracting && !skipTracker.isSkipping
    }

    var body: some View {
        AdaptiveSheetContainer(isPresenting: $isPresentingMetrics) {
            ZStack {
                main()
                bottomBar()
                topBar()
            }
            .animation(.defaultLinear, value: shouldHideInterface)
        } sheet: {
            MetricsView(metricsCollector: metricsCollector)
        }
        .statusBarHidden(isFullScreen ? isUserInterfaceHidden : false)
        .onContinuousHover { phase in
            switch phase {
            case .active:
                visibilityTracker.reset()
            case .ended:
                break
            }
        }
        .bind(visibilityTracker, to: player)
        .bind(metricsCollector, to: player)
        .bind(progressTracker, to: player)
    }

    private var isFullScreen: Bool {
        layout == .inline || layout == .maximized
    }

    private var gravity: AVLayerVideoGravity {
        layoutInfo.isOverCurrentContext ? selectedGravity : .resizeAspect
    }

    private var isUserInterfaceHidden: Bool {
        visibilityTracker.isUserInterfaceHidden && !shouldKeepControlsAlwaysVisible && !player.canReplay()
    }

    private var title: String? {
        player.metadata.title
    }

    private var subtitle: String? {
        player.metadata.subtitle
    }

    private var isMonoscopic: Bool {
        player.metadata.viewport == .monoscopic
    }

    private func main() -> some View {
        GeometryReader { geometry in
            ZStack {
                video()
                    .simultaneousGesture(skipGesture(in: geometry))
                    .simultaneousGesture(toggleGesture(), isEnabled: isToggleGestureEnabled)
                    .accessibilityElement()
                    .accessibilityLabel("Video")
                    .accessibilityHint("Double tap to toggle controls")
                    .accessibilityAction(.default, visibilityTracker.toggle)
                    .accessibilityHidden(shouldKeepControlsAlwaysVisible)
                controls()
            }
            .animation(.defaultLinear, values: isUserInterfaceHidden, isInteracting)
            .simultaneousGesture(magnificationGesture(), isEnabled: layoutInfo.isOverCurrentContext)
            .simultaneousGesture(visibilityResetGesture())
            .overlay(alignment: .center) {
                skipOverlay(skipTracker: skipTracker, in: geometry)
            }
        }
        .animation(.defaultLinear, value: skipTracker.state)
        .ignoresSafeArea()
        .supportsHighSpeed(!isMonoscopic, for: player)
        .readLayout(into: $layoutInfo)
        .bind(skipTracker, to: player)
    }

    private func sliderBackground() -> some View {
        Rectangle()
            .foregroundColor(.white)
            .opacity(0.1)
            .background(.ultraThinMaterial)
    }

    private func artwork(for imageSource: ImageSource) -> some View {
        LazyImage(source: imageSource) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .animation(.easeIn(duration: 0.2), value: imageSource)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func video() -> some View {
        ZStack {
            if player.mediaType == .audio {
                artwork(for: player.metadata.imageSource)
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
        .opacity(player.mediaType != .unknown ? 1 : 0)
        .animation(.easeIn(duration: 0.2), values: player.mediaType, player.isExternalPlaybackActive)
    }

    private func controls() -> some View {
        GeometryReader { geometry in
            ZStack {
                Color(white: 0, opacity: 0.5)
                    .simultaneousGesture(skipGesture(in: geometry))
                    .simultaneousGesture(toggleGesture(), isEnabled: isToggleGestureEnabled)
                    .ignoresSafeArea()
                ControlsView(player: player, progressTracker: progressTracker, skipTracker: skipTracker)
            }
            .opacity(shouldHideInterface ? 0 : 1)
        }
    }

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

extension PlaybackView {
    func supportsPictureInPicture(_ supportsPictureInPicture: Bool = true) -> PlaybackView {
        var view = self
        view.supportsPictureInPicture = supportsPictureInPicture
        return view
    }
}

private extension MainView {
    func toggleGesture() -> some Gesture {
        TapGesture()
            .onEnded(visibilityTracker.toggle)
    }

    func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                selectedGravity = scale > 1.0 ? .resizeAspectFill : .resizeAspect
            }
    }

    func visibilityResetGesture() -> some Gesture {
        TapGesture()
            .onEnded(visibilityTracker.reset)
    }

    func skipGesture(in geometry: GeometryProxy) -> some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                if skipTracker.requestSkip(value.location.x < geometry.size.width / 2 ? .backward : .forward) {
                    visibilityTracker.hide()
                }
            }
    }
}

private extension MainView {
    func skipOverlay(skipTracker: SkipTracker, in geometry: GeometryProxy) -> some View {
        Group {
            switch skipTracker.state {
            case let .skippingBackward(interval):
                Label("-\(Int(interval))s", systemImage: "backward.fill")
                    .offset(x: -geometry.size.width / 4)
            case let .skippingForward(interval):
                Label("+\(Int(interval))s", systemImage: "forward.fill")
                    .offset(x: geometry.size.width / 4)
            case .inactive:
                EmptyView()
            }
        }
        .bold()
        .foregroundStyle(.white)
        .labelStyle(.vertical)
        .contentTransition(.numericText())
    }
}

private extension MainView {
    func topBar() -> some View {
        HStack {
            topLeadingButtons()
            Spacer()
            topTrailingButtons()
        }
        .topBarStyle()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    func topLeadingButtons() -> some View {
        HStack(spacing: 20) {
            CloseButton()
            if supportsPictureInPicture {
                PiPButton()
            }
            routePickerView()
        }
        .opacity(shouldHideInterface ? 0 : 1)
        .contentShape(.rect)
    }

    func topTrailingButtons() -> some View {
        HStack(spacing: 20) {
            LoadingIndicator(player: player)
            if !shouldHideInterface {
                VolumeButton(player: player)
            }
        }
        .contentShape(.rect)
    }

    func routePickerView() -> some View {
        RoutePickerView(prioritizesVideoDevices: prioritizesVideoDevices)
            .tint(.white)
            .aspectRatio(contentMode: .fit)
            .frame(width: 20)
    }
}

private extension MainView {
    func bottomBar() -> some View {
        VStack(spacing: 20) {
            skipButton()
            bottomControls()
        }
        .animation(.defaultLinear, values: isUserInterfaceHidden, isInteracting)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    func bottomControls() -> some View {
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
        .contentShape(.rect)
        .opacity(isUserInterfaceHidden ? 0 : 1)
    }

    func bottomButtons() -> some View {
        HStack(spacing: 20) {
            LiveButton(player: player, progressTracker: progressTracker)
            SettingsMenu(
                player: player,
                isOverCurrentContext: layoutInfo.isOverCurrentContext,
                isPresentingMetrics: $isPresentingMetrics,
                gravity: $selectedGravity
            )
            FullScreenButton(layout: $layout)
        }
        .opacity(isFullScreen && shouldHideInterface ? 0 : 1)
    }

    func metadata() -> some View {
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
        .opacity(shouldHideInterface ? 0 : 1)
    }

    func skipButton() -> some View {
        SkipButton(player: player, progressTracker: progressTracker)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    PlaybackView(player: Player(item: URLMedia.appleBasic_4_3_HLS.item()))
}
