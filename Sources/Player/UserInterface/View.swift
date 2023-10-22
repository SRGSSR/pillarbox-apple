//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension View {
    /// Assigns to a binding property a value emitted by the given player's publisher.
    /// - Parameters:
    ///   - player: The player.
    ///   - keyPath: The key path to extract.
    ///   - binding: The binding to which the value must be assigned.
    ///   - Returns: A view that fills the given binding when the player's publisher emits an
    ///   event.
    @ViewBuilder
    func onReceive<T>(player: Player?, assign keyPath: KeyPath<PlayerProperties, T>, to binding: Binding<T>) -> some View
        where T: Equatable {
            if let player {
                onReceive(player.propertiesPublisher, assign: keyPath, to: binding)
            }
            else {
                self
            }
    }
}

/// A set of SwiftUI View extensions for handling Picture in Picture events.
public extension View {
    /// Sets the action to be performed when Picture in Picture will start.
    ///
    /// - Parameters:
    ///   - pictureInPicture: The `PictureInPicture` instance.
    ///   - willStart: A closure to be executed when Picture in Picture is about to start.
    /// - Returns: A modified View.
    func onPictureInPictureWillStart(_ pictureInPicture: PictureInPicture, willStart: @escaping () -> Void) -> some View {
        onAppear {
            pictureInPicture.willStartPictureInPicture = willStart
        }
    }

    /// Sets the action to be performed when Picture in Picture did start.
    ///
    /// - Parameters:
    ///   - pictureInPicture: The `PictureInPicture` instance.
    ///   - didStart: A closure to be executed when Picture in Picture has started.
    /// - Returns: A modified View.
    func onPictureInPictureDidStart(_ pictureInPicture: PictureInPicture, didStart: @escaping () -> Void) -> some View {
        onAppear {
            pictureInPicture.didStartPictureInPicture = didStart
        }
    }

    /// Sets the action to be performed when Picture in Picture is restored.
    ///
    /// - Parameters:
    ///   - pictureInPicture: The `PictureInPicture` instance.
    ///   - restore: A closure that takes another closure as an argument to indicate whether the restoration was successful or not.
    /// - Returns: A modified View.
    func onPictureInPictureRestore(_ pictureInPicture: PictureInPicture, restore: @escaping (@escaping (Bool) -> Void) -> Void) -> some View {
        onAppear {
            pictureInPicture.restorePictureInPicture = restore
        }
    }
}
