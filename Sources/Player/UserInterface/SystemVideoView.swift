//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

private struct _SystemVideoView: UIViewControllerRepresentable {
    let player: Player

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
    }
}

/// A view providing the standard system playback user experience.
public struct SystemVideoView: View {
    private let player: Player

    public var body: some View {
        _SystemVideoView(player: player)
#if os(tvOS)
            .onDisappear {
                // Avoid sound continuing in background on tvOS, see https://github.com/SRGSSR/pillarbox-apple/issues/520
                player.pause()
            }
#endif
    }

    /// Creates the view.
    ///
    /// - Parameter player: The player whose contents will be rendered.
    public init(player: Player) {
        self.player = player
    }
}
