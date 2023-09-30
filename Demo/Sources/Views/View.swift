//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct PulseSymbolEffect: ViewModifier {
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

private struct ReplaceSymbolEffect: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, tvOS 17.0, *) {
            content
                .contentTransition(.symbolEffect(.replace))
        }
        else {
            content
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

    func tracked(name: String, levels: [String] = []) -> some View {
        tracked(
            comScore: .init(name: name),
            commandersAct: .init(name: name, type: "content", levels: levels)
        )
    }

    func pulseSymbolEffect() -> some View {
        modifier(PulseSymbolEffect())
    }

    func replaceSymbolEffect() -> some View {
        modifier(ReplaceSymbolEffect())
    }
}
