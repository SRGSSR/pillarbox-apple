//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

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
                } else {
                    timer = Timer.scheduledTimer(withTimeInterval: minimumPressDuration, repeats: false) { _ in
                        action(false)
                    }
                }
            }
    }

    init(minimumPressDuration: TimeInterval = 2, content: @escaping () -> Content, action: @escaping (_ finished: Bool) -> Void) {
        self.minimumPressDuration = minimumPressDuration
        self.content = content
        self.action = action
    }

    private func longPressGesture() -> some Gesture {
        LongPressGesture(minimumDuration: .infinity)
            .updating($isLongPressing) { value, state, _ in
                state = value
            }
    }
}

private struct LongPressPlaybackInfoView: View {
    var body: some View {
        HStack {
            Text("x 2")
                .font(.footnote)
                .bold()
            HStack(spacing: 3) {
                ForwardArrowView()
                ForwardArrowView()
            }
        }
        .padding(10)
        .foregroundStyle(.white)
        .background(.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: .infinity))
    }
}

private struct ForwardArrowView: View {
    var body: some View {
        Image(systemName: "arrowtriangle.forward.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 10)
    }
}

struct LongPressPlaybackView<Content>: View where Content: View {
    @State private var initialSpeed: Float = 0

    let minimumPressDuration: TimeInterval
    let player: Player
    @ViewBuilder let content: () -> Content

    var body: some View {
        LongPressView(minimumPressDuration: minimumPressDuration, content: content) { finished in
            player.setDesiredPlaybackSpeed(finished ? initialSpeed : 2)
        }
        .onAppear {
            initialSpeed = player.effectivePlaybackSpeed
        }
    }

    init(minimumPressDuration: TimeInterval = 2, player: Player, content: @escaping () -> Content) {
        self.minimumPressDuration = minimumPressDuration
        self.player = player
        self.content = content
    }
}

extension View {
    func longPressPlayback(_ player: Player) -> some View {
        LongPressPlaybackView(player: player) {
            self
        }
    }
}
