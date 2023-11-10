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
/// For the button to be visible one of its parent must be enabled for in-app Picture in Picture. In SwiftUI apps
/// this is achieved by applying the `View.enabledForInAppPictureInPictureWithCleanup(perform:)` modifier. In UIKit
/// apps `PictureInPicture.restoreFromInAppPictureInPicture()` must be called instead when the playback view appears.
public struct PictureInPictureButton<Content>: View where Content: View {
    private let content: (Bool) -> Content

    @State private var isPossible = false
    @State private var isActive = false
    @State private var isInAppPossible = false

    public var body: some View {
        ZStack {
            if isPossible && isInAppPossible {
                Button(action: CustomPictureInPicture.shared.toggle) {
                    content(isActive)
                }
                .onReceive(CustomPictureInPicture.shared.$isActive) { isActive = $0 }
            }
        }
        .onReceive(CustomPictureInPicture.shared.$isPossible) { isPossible = $0 }
        .onReceive(CustomPictureInPicture.shared.$isInAppPossible) { isInAppPossible = $0 }
    }

    /// Creates a Picture in Picture button.
    ///
    /// - Parameter content: The button body. Use the `isActive` Boolean to adjust your presentation according
    ///   to the current Picture in Picture state.
    public init(@ViewBuilder content: @escaping (_ isActive: Bool) -> Content) {
        self.content = content
    }
}
