//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct LongPressPlaybackView<Content>: View where Content: View {
    @State private var speed: Float?

    private var canSpeedUp: Bool {
        player.playbackSpeedRange.contains(2) && player.playbackState == .playing && speed != 2
    }

    let minimumPressDuration: TimeInterval
    @ObservedObject var player: Player
    let content: () -> Content

    var body: some View {
        LongPressView(minimumPressDuration: minimumPressDuration, content: content) { finished in
            if !finished {
                speed = player.effectivePlaybackSpeed
                player.setDesiredPlaybackSpeed(2)
            }
            else if let speed {
                player.setDesiredPlaybackSpeed(speed)
                self.speed = nil
            }
        }
        .overlay(alignment: .top) {
            if speed != nil, canSpeedUp {
                LongPressPlaybackInfoView()
                    .padding()
            }
        }
    }
}

private struct LongPressPlaybackInfoView: View {
    var body: some View {
        Text("2× \(Image(systemName: "forward.fill"))")
            .font(.footnote)
            .bold()
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(.white)
            .background(.black.opacity(0.7))
            .clipShape(Capsule())
    }
}

private struct LongPressView<Content>: View where Content: View {
    @GestureState private var isLongPressing = false
    @State private var timer: Timer?

    let minimumPressDuration: TimeInterval
    let content: () -> Content
    let action: (_ finished: Bool) -> Void

    var body: some View {
        content()
            .simultaneousGesture(longPressGesture())
            .onChange(of: isLongPressing) { isPressing in
                timer?.invalidate()
                if !isPressing {
                    action(true)
                }
                else {
                    timer = Timer.scheduledTimer(withTimeInterval: minimumPressDuration, repeats: false) { _ in
                        action(false)
                    }
                }
            }
    }

    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity)
            .updating($isLongPressing) { value, state, _ in
                state = value
            }
    }
}

extension View {
    func longPressPlayback(_ player: Player) -> some View {
        LongPressPlaybackView(minimumPressDuration: 1, player: player) {
            self
        }
    }
}
