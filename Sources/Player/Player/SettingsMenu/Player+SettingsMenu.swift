//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
public extension Player {
    /// Returns content for a standard player settings menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user interacts with an item from the menu.
    ///
    /// The returned view is meant to be used as content of a `Menu`. Using it for any other purpose has undefined
    /// behavior.
    func standardSettingsMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ update: SettingsUpdate) -> Void = { _ in }
    ) -> some View {
        SettingsMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a playback speed settings menu.
    ///
    /// - Parameters:
    ///    - speeds: The offered playback speeds.
    ///    - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func playbackSpeedMenu(
        speeds: Set<Float> = [0.5, 1, 1.25, 1.5, 2],
        action: @escaping (_ speed: Float) -> Void = { _ in }
    ) -> some View {
        PlaybackSpeedMenuContent(speeds: speeds, action: action, player: self)
    }

    /// Returns content for a media selection settings menu.
    ///
    /// - Parameters:
    ///    - characteristic: The characteristic for which selection is made.
    ///    - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func mediaSelectionMenu(
        characteristic: AVMediaCharacteristic,
        action: @escaping (_ option: MediaSelectionOption) -> Void = { _ in }
    ) -> some View {
        MediaSelectionMenuContent(characteristic: characteristic, action: action, player: self)
    }

    /// Returns the content for a zoom settings menu.
    ///
    /// - Parameters:
    ///   - gravity: A binding to the gravity value to control.
    ///   - action: The action to perform when the user selects an item from the menu.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    func zoomMenu(
        gravity: Binding<AVLayerVideoGravity>,
        action: @escaping (_ gravity: AVLayerVideoGravity) -> Void = { _ in }
    ) -> some View {
        ZoomMenuContent(gravity: gravity, action: action, player: self)
    }

    /// Returns content for a route picker button.
    /// 
    /// - Parameter activeTintColor: The view's tint color when AirPlay is active or `nil` for the default color.
    ///
    /// This view represents a menu item that users tap to stream audio/video content to a media receiver, such as a Mac
    /// or Apple TV. When the user taps the item, the system presents a popover that displays all of the nearby AirPlay
    /// devices that can receive and play back media. If your app prefers video content, the system displays video-capable
    /// devices higher in the list.
    ///
    /// The returned view is intended for use as the content of a `Menu`. Using it for any other purpose results in
    /// undefined behavior.
    ///
    /// > Important: This button is not available for iPad applications run on macOS or using Catalyst.
    func routePickerMenu(activeTintColor: Color? = nil) -> some View {
        RoutePickerMenuContent(activeTintColor: activeTintColor, player: self)
    }
}
