//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct PulseSymbolEffect17: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, tvOS 17.0, *) {
            content
                .symbolEffect(.pulse)
        }
        else {
            content
        }
    }
}

private struct ScrollClipDisabled17: ViewModifier {
    let isDisabled: Bool

    init(_ isDisabled: Bool) {
        self.isDisabled = isDisabled
    }

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 17.0, tvOS 17.0, *) {
                content
                    .scrollClipDisabled(isDisabled)
            }
            else {
                content
            }
        }
    }
}

private struct ScaleEffect17: ViewModifier {
    let scale: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 17.0, tvOS 17.0, *) {
            content
                .scaleEffect(scale)
        }
        else {
            content
        }
    }
}

private struct TapGesturesModifier: ViewModifier {
    let onLeftDoubleTap: () -> Void
    let onRightDoubleTap: () -> Void

    @State private var doubleTapTask: DispatchWorkItem?
    @State private var doubleTapCount: Int = 2
    @State private var allowsHitTesting = true

    private var leftDoubleTap: some Gesture {
        TapGesture(count: doubleTapCount)
            .onEnded {
                doubleTapTask?.cancel()

                onLeftDoubleTap()
                doubleTapCount = 1

                let task = DispatchWorkItem {
                    doubleTapCount = 2
                    allowsHitTesting = true
                    doubleTapTask = nil
                }
                doubleTapTask = task
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
            }
    }

    private var rightDoubleTap: some Gesture {
        TapGesture(count: doubleTapCount)
            .onEnded {
                doubleTapTask?.cancel()

                onRightDoubleTap()
                doubleTapCount = 1

                let task = DispatchWorkItem {
                    doubleTapCount = 2
                    allowsHitTesting = true
                    doubleTapTask = nil
                }
                doubleTapTask = task
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
            }
    }

    private var initialDoubleTap: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                allowsHitTesting = false
            }
    }

    func body(content: Content) -> some View {
        content
            .gesture(initialDoubleTap)
            .allowsHitTesting(allowsHitTesting)
            .overlay {
                HStack(spacing: 0) {
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(leftDoubleTap)
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(rightDoubleTap)
                }
                .allowsHitTesting(!allowsHitTesting)
            }
    }
}

extension View {
    /// Prevents touch propagation to views located below the receiver.
    func preventsTouchPropagation() -> some View {
        background(Color(white: 1, opacity: 0.0001))
    }

    func animation<V1, V2>(_ animation: Animation?, values v1: V1, _ v2: V2) -> some View where V1: Equatable, V2: Equatable {
        self.animation(animation, value: v1)
            .animation(animation, value: v2)
    }

    func animation<V1, V2, V3>(_ animation: Animation?, values v1: V1, _ v2: V2, _ v3: V3) -> some View where V1: Equatable, V2: Equatable, V3: Equatable {
        self.animation(animation, value: v1)
            .animation(animation, value: v2)
            .animation(animation, value: v3)
    }

    func tracked(name: String, levels: [String] = []) -> some View {
        tracked(commandersAct: .init(name: name, type: "content", levels: levels))
    }

    func pulseSymbolEffect17() -> some View {
        modifier(PulseSymbolEffect17())
    }

    func scrollClipDisabled17(_ disabled: Bool = true) -> some View {
        modifier(ScrollClipDisabled17(disabled))
    }

    func scaleEffect17(_ scale: CGFloat) -> some View {
        modifier(ScaleEffect17(scale: scale))
    }
}

extension View {
    func headerStyle() -> some View {
#if os(tvOS)
        self
            .font(.headline)
            .foregroundStyle(.gray)
            .fontWeight(.semibold)
            .padding(20)
#else
        self
#endif
    }
}

extension View {
    @ViewBuilder
    func topBarStyle(_ apply: Bool = true) -> some View {
        if apply {
            padding(.horizontal)
                .frame(minHeight: 35)
        }
        else {
            self
        }
    }
}

extension View {
    func tapGestures(onLeftDoubleTap: @escaping () -> Void, onRightDoubleTap: @escaping () -> Void) -> some View {
        modifier(TapGesturesModifier(onLeftDoubleTap: onLeftDoubleTap, onRightDoubleTap: onRightDoubleTap))
    }
}
