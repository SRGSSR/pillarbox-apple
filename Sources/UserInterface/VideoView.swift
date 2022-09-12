//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UIKit

public final class VideoLayerView: UIView {
    override public class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

public struct VideoView: UIViewRepresentable {
    let player: Player?
    let gravity: AVLayerVideoGravity

    public init(player: Player?, gravity: AVLayerVideoGravity = .resizeAspect) {
        self.player = player
        self.gravity = gravity
    }

    public func makeUIView(context: Context) -> VideoLayerView {
        let view = VideoLayerView()
        view.backgroundColor = .clear
        view.player = player?.rawPlayer
        view.playerLayer.videoGravity = gravity
        return view
    }

    public func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player?.rawPlayer
    }
}
