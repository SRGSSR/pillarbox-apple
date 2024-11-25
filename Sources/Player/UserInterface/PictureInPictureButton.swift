//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A button to toggle Picture in Picture.
///
/// The button is automatically hidden when Picture in Picture is not available. The body closure is provided a
/// Boolean indicating when Picture in Picture is active.
///
/// For the button to be visible at least one `VideoView` or `SystemVideoView` must be enabled for in-app Picture in
/// Picture by applying the `View/enabledForInAppPictureInPicture(persisting:)` modifier to one of its parent views.
public struct PictureInPictureButton<Content>: View where Content: View {
    private let content: (Bool) -> Content

    @State private var isPossible = false
    @State private var isActive = false

    public var body: some View {
        Group {
            if isPossible && PictureInPicture.shared.persistable != nil {
                Button(action: PictureInPicture.shared.custom.toggle) {
                    content(isActive)
                }
                .hoverEffect()
                .onReceive(PictureInPicture.shared.custom.$isActive) { isActive = $0 }
            }
        }
        .onReceive(PictureInPicture.shared.custom.$isPossible) { isPossible = $0 }
    }

    /// Creates a Picture in Picture button.
    ///
    /// - Parameter content: The button body. Use the `isActive` Boolean to adjust your presentation according
    ///   to the current Picture in Picture state.
    public init(@ViewBuilder content: @escaping (_ isActive: Bool) -> Content) {
        self.content = content
    }
}
