//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SwiftUI

private struct MarqueeView: View {
    static let spacing: CGFloat = 40
    let text: String
    let width: CGFloat
    let isActive: Bool

    @State private var textWidth: CGFloat = 0
    @State private var translationX: CGFloat = 0

    private var shouldScroll: Bool {
        textWidth > width
    }

    @State private var timerPublisher = Self.timerPublisher()

    var body: some View {
        HStack(spacing: Self.spacing) {
            Text(text)
                .fixedSize()
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                textWidth = geometry.size.width
                            }
                    }
                }
            if shouldScroll {
                Text(text)
                    .fixedSize()
            }
        }
        .offset(x: translationX)
        .frame(width: width, alignment: .leading)
        .clipped()
        .onReceive(timerPublisher) { _ in
            if isActive && shouldScroll {
                translationX -= 1
            }

            if translationX <= -(textWidth + Self.spacing) || !isActive {
                translationX = 0
                timerPublisher = Self.timerPublisher()
            }
        }
    }

    init(_ text: String, isActive: Bool, width: CGFloat) {
        self.text = text
        self.isActive = isActive
        self.width = width
    }

    private static func timerPublisher() -> AnyPublisher<Void, Never> {
        Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .delay(for: .seconds(3), scheduler: RunLoop.main)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

// TODO: Remove once tvOS 26 is not supported anymore.
struct ChapterCell: View {
    private static let aspectRatio: CGFloat = 16 / 9

    private static let width: CGFloat = 320
    private static let descriptionPadding: CGFloat = 10
    private static let heightExtension: CGFloat = 48

    private static var height = width / aspectRatio + heightExtension

    let chapter: Chapter
    let isHighlighted: Bool
    let isFocused: Bool
    let action: () -> Void

    private var accessibilityTraits: AccessibilityTraits {
        isHighlighted ? [.isSelected] : []
    }

    var body: some View {
        SwiftUI::Button(action: action) {
            ZStack {
                artwork()
                description()
            }
            .background(Color(white: 0.1))
        }
        .frame(width: Self.width, height: Self.height)
#if os(tvOS)
        .buttonStyle(.card)
#endif
        .accessibilityAddTraits(accessibilityTraits)
    }

    @ContentBuilder
    private func artwork() -> some View {
        LazyImage(source: chapter.imageSource) { image in
            image
                .resizable()
                .aspectRatio(Self.aspectRatio, contentMode: .fit)
                .backgroundExtension(spacing: Self.heightExtension)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .center)
        }
    }

    private func description() -> some View {
        VStack(alignment: .leading) {
            subtitle()
            title()
        }
        .padding(Self.descriptionPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    @ContentBuilder
    private func subtitle() -> some View {
        if isHighlighted {
            Text("Watching", bundle: .module, comment: "Marker text for the current chapter")
                .textCase(.uppercase)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundStyle(isFocused ? .primary : .secondary)
        }
    }

    @ContentBuilder
    private func title() -> some View {
        if let title = chapter.title {
            MarqueeView(title, isActive: isFocused, width: Self.width - (Self.descriptionPadding * 2))
                .font(.system(size: 24))
                .fontWeight(.medium)
        }
    }
}

private extension View {
    @ContentBuilder
    func backgroundExtension(spacing: CGFloat) -> some View {
        if #available(iOS 26, tvOS 26, *) {
            // Trick, see https://nilcoalescing.com/blog/BackgroundExtensionEffectInSwiftUI/
            backgroundExtensionEffect()
                .safeAreaInset(edge: .bottom, spacing: spacing) {
                    Color.clear
                        .frame(height: 0)
                }
        }
        else {
            self
        }
    }
}
