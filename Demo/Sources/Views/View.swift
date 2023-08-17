//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import SwiftUI

private struct SymbolPulseEffect: ViewModifier {
    func body(content: Content) -> some View {
        // TODO: Remove when Xcode 15 has been released
#if compiler(>=5.9)
        if #available(iOS 17.0, tvOS 17.0, *) {
            content
                .symbolEffect(.pulse)
        }
        else {
            content
        }
#else
        content
#endif
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

    func symbolPulseEffect() -> some View {
        modifier(SymbolPulseEffect())
    }
}
