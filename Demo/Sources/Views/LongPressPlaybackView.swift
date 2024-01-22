//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

#if os(iOS)
private struct LongPressView<Content>: View where Content: View {
    @GestureState private var isLongPressing = false
    @State private var timer: Timer?

    let minimumPressDuration: TimeInterval
    @ViewBuilder let content: () -> Content
    let action: (_ finished: Bool) -> Void

    var body: some View {
        content()
            .simultaneousGesture(longPressGesture())
            .onChange(of: isLongPressing) { isChanged in
                timer?.invalidate()
                if !isChanged {
                    action(true)
                }
                else {
                    timer = Timer.scheduledTimer(withTimeInterval: minimumPressDuration, repeats: false) { _ in
                        action(false)
                    }
                }
            }
    }

    init(minimumPressDuration: TimeInterval = 1, content: @escaping () -> Content, action: @escaping (_ finished: Bool) -> Void) {
        self.minimumPressDuration = minimumPressDuration
        self.content = content
        self.action = action
    }

    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
            .updating($isLongPressing) { value, state, transaction in
                state = value
                transaction.animation = .easeIn(duration: 2.0)
            }
    }
}

private struct LongPressPlaybackInfoView: View {
    var body: some View {
        HStack {
            Text("2× \(Image(systemName: "forward.fill"))")
                .font(.footnote)
                .bold()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundStyle(.white)
        .background(.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}

struct LongPressPlaybackView<Content>: View where Content: View {
    @State private var speed: Float?
    @State private var isFinished = true
    @State private var isBusy = false
    @State private var playbackState: PlaybackState = .playing

    private var canSpeedUp: Bool {
        player.playbackSpeedRange.contains(2)
    }
    private var isPlaying: Bool {
        playbackState == .playing
    }

    let minimumPressDuration: TimeInterval
    let player: Player
    @ViewBuilder let content: () -> Content

    var body: some View {
        LongPressView(minimumPressDuration: minimumPressDuration, content: content) { finished in
            if !finished {
                speed = player.effectivePlaybackSpeed
            }
            if let speed {
                player.setDesiredPlaybackSpeed(finished ? speed : 2)
            }
            isFinished = finished
        }
        .overlay {
            if !isFinished, !isBusy, isPlaying, canSpeedUp {
                LongPressPlaybackInfoView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top)
            }
        }
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
        .onReceive(player: player, assign: \.playbackState, to: $playbackState)
        .onChange(of: player.effectivePlaybackSpeed) { speed in
            if isFinished {
                self.speed = speed
            }
        }
    }

    init(minimumPressDuration: TimeInterval = 1, player: Player, content: @escaping () -> Content) {
        self.minimumPressDuration = minimumPressDuration
        self.player = player
        self.content = content
    }
}
#endif

extension View {
    func longPressPlayback(_ player: Player) -> some View {
#if os(iOS)
        LongPressPlaybackView(player: player) {
            self
        }
#else
        self
#endif
    }
}
