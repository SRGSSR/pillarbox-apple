//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// TODO: Remove once tvOS 26 is not supported anymore.
struct ChapterCell: View {
    private static let aspectRatio: CGFloat = 16 / 9

    private static let width: CGFloat = 320
    private static let heightExtension: CGFloat = 48

    private static var height = width / aspectRatio + heightExtension

    let chapter: Chapter
    let isHighlighted: Bool
    let action: () -> Void

    private var accessibilityTraits: AccessibilityTraits {
        isHighlighted ? [.isSelected] : []
    }

    var body: some View {
        SwiftUI.Button(action: action) {
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

    @ViewBuilder
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
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    @ViewBuilder
    private func subtitle() -> some View {
        if isHighlighted {
            Text("Watching", bundle: .module, comment: "Marker text for the current chapter")
                .textCase(.uppercase)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func title() -> some View {
        if let title = chapter.title {
            Text(title)
                .font(.system(size: 24))
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}

private extension View {
    @ViewBuilder
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
