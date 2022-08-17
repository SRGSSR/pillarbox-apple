//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UIKit

public final class PlayerLayerView: UIView {
    override public class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

public struct PlayerView: UIViewRepresentable {
    let player: Player?

    public init(player: Player?) {
        self.player = player
    }

    public func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.player = player?.player
        return view
    }

    public func updateUIView(_ uiView: PlayerLayerView, context: Context) {
        uiView.player = player?.player
    }
}
