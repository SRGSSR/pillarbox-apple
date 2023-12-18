//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension View {
    /// Assigns to a binding property a value emitted by the given player's publisher.
    ///
    /// - Parameters:
    ///   - player: The player.
    ///   - keyPath: The key path to extract.
    ///   - binding: The binding to which the value must be assigned.
    ///   - Returns: A view that fills the given binding when the player's publisher emits an
    ///   event.
    ///
    /// > Warning: Be careful to associate often updated state to local view scopes to avoid unnecessary view body refreshes. Please
    /// refer to <doc:state-observation> for more information.
    @ViewBuilder
    func onReceive<T>(player: Player?, assign keyPath: KeyPath<PlayerProperties, T>, to binding: Binding<T>) -> some View where T: Equatable {
        if let player {
            onReceive(player.propertiesPublisher, assign: keyPath, to: binding)
        }
        else {
            self
        }
    }
}

public extension View {
    /// Enables the view for in-app Picture in Picture.
    /// 
    /// - Parameters:
    ///   - setup: A closure to setup resources associated with the view when it appears.
    ///   - cleanup: A closure to clean resources associated with the view when it disappears, or when Picture in Picture
    ///     ends.
    func enabledForInAppPictureInPictureWithSetup(perform setup: @escaping () -> Void, cleanup: @escaping () -> Void) -> some View {
        onAppear {
            PictureInPicture.shared.restoreFromInAppPictureInPictureWithSetup(perform: setup)
        }
        .onDisappear {
            PictureInPicture.shared.enableInAppPictureInPictureWithCleanup(perform: cleanup)
        }
    }
}
