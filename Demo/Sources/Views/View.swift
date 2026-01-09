//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct SearchScopes16<V, S>: ViewModifier where V: Hashable, S: View {
    let binding: Binding<V>
    @ViewBuilder let scopes: () -> S

    func body(content: Content) -> some View {
        if #available(iOS 16.0, tvOS 16.4, *) {
            content
                .searchScopes(binding, scopes: scopes)
        }
        else {
            content
        }
    }
}

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

extension View {
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

    func searchScopes16_4<V, S>(_ binding: Binding<V>, @ViewBuilder scopes: @escaping () -> S) -> some View where V: Hashable, S: View {
        modifier(SearchScopes16(binding: binding, scopes: scopes))
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
