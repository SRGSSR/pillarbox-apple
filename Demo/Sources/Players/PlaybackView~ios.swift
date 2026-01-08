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

// swiftlint:disable file_types_order

private struct MainView: View {
    @ObservedObject var player: Player
    @Binding var layout: PlaybackView.Layout
    let supportsPictureInPicture: Bool
    let progressTracker: ProgressTracker

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

private struct SkipButton: View {
    let player: Player
    @ObservedObject var progressTracker: ProgressTracker

    private var skippableTimeRange: TimeRange? {
        player.skippableTimeRange(at: progressTracker.time)
    }

    var body: some View {
        Button(action: skip) {
            Text("Skip")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(white: 0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(Color(white: 0.3))
                }
        }
        .opacity(skippableTimeRange != nil ? 1 : 0)
        .animation(.easeInOut, value: skippableTimeRange)
    }

    private func skip() {
        guard let skippableTimeRange else { return }
        player.seek(to: skippableTimeRange.end)
    }
}

private struct ControlsView: View {
    @ObservedObject var player: Player
    let progressTracker: ProgressTracker
    let skipTracker: SkipTracker

    var body: some View {
        HStack(spacing: 30) {
            SkipBackwardButton(player: player, progressTracker: progressTracker, skipTracker: skipTracker)
            PlaybackButton(player: player)
            SkipForwardButton(player: player, progressTracker: progressTracker, skipTracker: skipTracker)
        }
        .animation(.defaultLinear, value: player.playbackState)
    }
}

private struct SkipBackwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var skipTracker: SkipTracker

    var body: some View {
        Button(action: skipBackward) {
            Image.goBackward(withInterval: player.configuration.backwardSkipInterval)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(player.canSkipBackward() && !skipTracker.isSkipping ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipBackward())
        .keyboardShortcut("s", modifiers: [])
        .hoverEffect()
        ._debugBodyCounter(color: .green)
    }

    private func skipBackward() {
        player.skipBackward()
    }
}

private struct SkipForwardButton: View {
    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var skipTracker: SkipTracker

    var body: some View {
        Button(action: skipForward) {
            Image.goForward(withInterval: player.configuration.forwardSkipInterval)
                .resizable()
                .tint(.white)
        }
        .aspectRatio(contentMode: .fit)
        .frame(height: 45)
        .opacity(player.canSkipForward() && !skipTracker.isSkipping ? 1 : 0)
        .animation(.defaultLinear, value: player.canSkipForward())
        .keyboardShortcut("d", modifiers: [])
        .hoverEffect()
        ._debugBodyCounter(color: .green)
    }

    private func skipForward() {
        player.skipForward()
    }
}

private struct FullScreenButton: View {
    @Binding var layout: PlaybackView.Layout

    var body: some View {
        if let imageName {
            Button(action: toggleFullScreen) {
                Image(systemName: imageName)
                    .tint(.white)
                    .font(.system(size: 20))
            }
            .keyboardShortcut("f", modifiers: [])
            .hoverEffect()
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

private struct VolumeButton: View {
    @ObservedObject var player: Player

    var body: some View {
        Button(action: toggleMuted) {
            Image(systemName: imageName)
                .tint(.white)
                .font(.system(size: 20))
        }
        .keyboardShortcut("m", modifiers: [])
        .hoverEffect()
    }

    private var imageName: String {
        player.isMuted ? "speaker.slash.fill" : "speaker.wave.3.fill"
    }

    private func toggleMuted() {
        player.isMuted.toggle()
    }
}

private struct SettingsMenu: View {
    let player: Player
    let isOverCurrentContext: Bool

    @Binding var isPresentingMetrics: Bool
    @Binding var gravity: AVLayerVideoGravity

    var body: some View {
        SwiftUI.Menu {
            player.standardSettingsMenu()
            QualityMenu(player: player)
            if isOverCurrentContext {
                player.zoomMenu(gravity: $gravity)
            }
            metricsMenu()
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.white)
        }
        .menuOrder(.fixed)
        .hoverEffect()
    }

    @ViewBuilder
    private func metricsMenu() -> some View {
        if !isPresentingMetrics {
            Button(action: showMetrics) {
                Label("Metrics", systemImage: "chart.bar")
            }
        }
    }

    private func showMetrics() {
        isPresentingMetrics = true
    }
}

private struct QualityMenu: View {
    let player: Player

    @AppStorage(UserDefaults.DemoSettingKey.qualitySetting.rawValue)
    private var qualitySetting: QualitySetting = .high

    var body: some View {
        SwiftUI.Menu {
            SwiftUI.Picker(selection: $qualitySetting) {
                ForEach(QualitySetting.allCases, id: \.self) { quality in
                    Text(quality.name).tag(quality)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
        } label: {
            Label("Quality", systemImage: "person.and.background.dotted")
            Text(qualitySetting.name)
        }
    }
}

private struct LoadingIndicator: View {
    let player: Player

    @State private var isBuffering = false

    var body: some View {
        ProgressView()
            .tint(.white)
            .opacity(isBuffering ? 1 : 0)
            .animation(.linear(duration: 0.1), value: isBuffering)
            .accessibilityHidden(true)
            .onReceive(player: player, assign: \.isBuffering, to: $isBuffering)
    }
}

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
                .hoverEffect()
                .accessibilityLabel("Jump to live")
            }
        }
        .onReceive(player: player, assign: \.streamType, to: $streamType)
    }

    private func skipToLive() {
        player.skipToDefault()
    }
}

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

private struct TimeSlider: View {
    private static let shortFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let longFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    private static let timeFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    @ObservedObject var player: Player
    @ObservedObject var progressTracker: ProgressTracker
    @ObservedObject var visibilityTracker: VisibilityTracker
    @State private var streamType: StreamType = .unknown
    @State private var buffer: Float = 0

    private var formattedElapsedTime: String? {
        if streamType == .onDemand {
            return Self.formattedTime((progressTracker.time - progressTracker.timeRange.start), duration: progressTracker.timeRange.duration)
        }
        else if let date = progressTracker.date() {
            return Self.timeFormatter.string(from: date)
        }
        else {
            return nil
        }
    }

    private var formattedTotalTime: String? {
        guard streamType == .onDemand else { return nil }
        return Self.formattedTime(progressTracker.timeRange.duration, duration: progressTracker.timeRange.duration)
    }

    private var isVisible: Bool {
        progressTracker.isProgressAvailable && streamType != .unknown
    }

    var body: some View {
        HStack {
            label(withText: formattedElapsedTime)
            slider()
            label(withText: formattedTotalTime)
        }
        .frame(height: 30)
        .accessibilityRepresentation {
            Slider(
                progressTracker: progressTracker,
                label: {
                    Text("Current position")
                },
                minimumValueLabel: {
                    label(withText: formattedElapsedTime)
                },
                maximumValueLabel: {
                    label(withText: formattedTotalTime)
                }
            )
        }
        .accessibilityAddTraits(.updatesFrequently)
        ._debugBodyCounter(color: .blue)
        .onReceive(player: player, assign: \.streamType, to: $streamType)
        .onReceive(player: player, assign: \.buffer, to: $buffer)
    }

    private static func formattedTime(_ time: CMTime, duration: CMTime) -> String? {
        guard time.isValid, duration.isValid else { return nil }
        if duration.seconds < 60 * 60 {
            return shortFormatter.string(from: time.seconds)!
        }
        else {
            return longFormatter.string(from: time.seconds)!
        }
    }

    private static func color(for timeRange: TimeRange) -> Color {
        switch timeRange.kind {
        case .credits:
            return .orange
        case .blocked:
            return .red
        }
    }

    private func slider() -> some View {
        HSlider(value: $progressTracker.progress) { progress, width in
            ZStack(alignment: .leading) {
                sliderBackground()
                sliderTimeRanges(width: width)
                sliderBuffer(width: width)
                sliderTrack(progress: progress, width: width)
            }
            .frame(height: progressTracker.isInteracting ? 16 : 8)
            .clipShape(.capsule)
            .shadow(color: .init(white: 0.2, opacity: 0.8), radius: 15)
            .opacity(isVisible ? 1 : 0)
            .animation(.defaultLinear, value: progressTracker.isInteracting)
        }
        .onEditingChanged { isEditing in
            progressTracker.isInteracting = isEditing
        }
        .onDragging(visibilityTracker.reset)
    }

    private func sliderBackground() -> some View {
        Color.white
            .opacity(0.1)
            .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func sliderTimeRanges(width: CGFloat) -> some View {
        if progressTracker.timeRange.isValid {
            let duration = progressTracker.timeRange.duration.seconds
            ForEach(player.metadata.timeRanges, id: \.self) { timeRange in
                Self.color(for: timeRange)
                    .opacity(0.7)
                    .frame(width: width * CGFloat(timeRange.duration.seconds / duration))
                    .offset(x: width * CGFloat(timeRange.start.seconds / duration))
            }
        }
    }

    private func sliderBuffer(width: CGFloat) -> some View {
        Color.white
            .opacity(0.3)
            .frame(width: CGFloat(buffer) * width)
            .animation(.defaultLinear, value: buffer)
    }

    private func sliderTrack(progress: CGFloat, width: CGFloat) -> some View {
        Color.white
            .frame(width: progress * width)
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

private struct AdaptiveSheetContainer<Content, Sheet>: View where Content: View, Sheet: View {
    @Binding var isPresenting: Bool

    @ViewBuilder let content: () -> Content
    @ViewBuilder let sheet: () -> Sheet

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        switch horizontalSizeClass {
        case .compact:
            compactView()
        default:
            defaultView()
        }
    }

    private func compactView() -> some View {
        content()
            .sheet(isPresented: $isPresenting) {
                NavigationStack {
                    sheet()
                }
                .presentationDetents([.medium, .large])
            }
    }

    private func defaultView() -> some View {
        HStack(spacing: 0) {
            content()
            if isPresenting {
                NavigationStack {
                    sheet()
                        .toolbar(content: toolbarContent)
                }
                .frame(width: 420)
            }
        }
        .animation(.default, value: isPresenting)
    }

    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Hide", action: close)
        }
    }

    private func close() {
        isPresenting = false
    }
}

private struct PlaybackButton: View {
    @ObservedObject var player: Player

    private var imageName: String {
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

    private var accessibilityLabel: String {
        if player.canReplay() {
            return "Restart"
        }
        else if player.shouldPlay {
            return "Pause"
        }
        else {
            return "Play"
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
        .accessibilityLabel(accessibilityLabel)
#if os(iOS)
        .keyboardShortcut(.space, modifiers: [])
        .hoverEffect()
#endif
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

struct PlaybackView: View {
    enum Layout {
        case inline
        case minimized
        case maximized
    }

    @ObservedObject private var player: Player
    @Binding private var layout: Layout
    @State private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 1))

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
        .bind(progressTracker, to: player)
    }

    private var isMonoscopic: Bool {
        player.metadata.viewport == .monoscopic
    }

    init(player: Player, layout: Binding<Layout> = .constant(.inline)) {
        self.player = player
        _layout = layout
    }

    private func mainView() -> some View {
        MainView(
            player: player,
            layout: $layout,
            supportsPictureInPicture: supportsPictureInPicture,
            progressTracker: progressTracker
        )
        ._debugBodyCounter()
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
    PlaybackView(player: Player(item: URLMedia.onDemandVideoLocalHLS.item()))
}

// swiftlint:enable file_types_order
