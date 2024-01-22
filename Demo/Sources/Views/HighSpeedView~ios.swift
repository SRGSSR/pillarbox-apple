//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct HighSpeedView<Content>: View where Content: View {
    @State private var speed: Float?

    private var displaysCapsule: Bool {
        player.playbackSpeedRange.contains(2) && player.playbackState == .playing && speed != 2
    }

    @ObservedObject var player: Player
    let content: () -> Content

    var body: some View {
        HighSpeedGestureView(content: content) { finished in
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
            if speed != nil, displaysCapsule {
                HighSpeedCapsule()
                    .padding()
            }
        }
    }
}

private struct HighSpeedCapsule: View {
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

private struct HighSpeedGestureView<Content>: View where Content: View {
    @GestureState private var isLongPressing = false
    @State private var timer: Timer?

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
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
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
    func supportsHighSpeed(for player: Player) -> some View {
        HighSpeedView(player: player) {
            self
        }
    }
}
