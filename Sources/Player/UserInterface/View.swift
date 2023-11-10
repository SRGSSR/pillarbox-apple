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
    /// Enables the view for in-app Picture in Picture, registering a cleanup closure to be performed when resources
    /// required by Picture in Picture initiated from the view are not needed anymore.
    ///
    /// - Parameter cleanup: A closure to clean resources associated with the view.
    func enabledForInAppPictureInPictureWithCleanup(perform cleanup: @escaping () -> Void) -> some View {
        onAppear {
            PictureInPicture.restoreFromInAppPictureInPicture()
        }
        .onWillAppear {
            CustomPictureInPicture.shared.stop()
        }
        .onDisappear {
            PictureInPicture.enableInAppPictureInPictureWithCleanup(perform: cleanup)
        }
    }
}
