//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A view that displays an image from an associated source.
///
/// The image is loaded when needed and delivered through usual `PlayerMetadata` updates.
public struct LazyImage<Content>: View where Content: View {
    private let source: ImageSource
    private let content: (Image) -> Content

    // swiftlint:disable:next missing_docs
    public var body: some View {
        ZStack {
            if let data = source.data, let image = UIImage(data: data) {
                content(Image(uiImage: image))
            }
        }
        .onAppear {
            source.fetchData()
        }
    }

    /// Creates a lazy image.
    ///
    /// - Parameters:
    ///   - source: The source to display the image from.
    ///   - content: A view builder to further customize how the actual loaded image is displayed.
    public init(
        source: ImageSource,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.source = source
        self.content = content
    }
}
