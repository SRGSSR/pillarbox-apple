//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

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
}

extension View {
    @ViewBuilder
    func pulseEffect() -> some View {
        // TODO: Remove when Xcode 15 has been released
#if compiler(>=5.9)
        if #available(iOS 17.0, tvOS 17.0, *) {
            symbolEffect(.pulse)
        }
        else {
            self
        }
#else
        self
#endif
    }

    @ViewBuilder
    func replaceEffect() -> some View {
        // TODO: Remove when Xcode 15 has been released
#if compiler(>=5.9)
        if #available(iOS 17.0, tvOS 17.0, *) {
            contentTransition(.symbolEffect(.replace))
        }
        else {
            self
        }
#else
        self
#endif
    }
}
