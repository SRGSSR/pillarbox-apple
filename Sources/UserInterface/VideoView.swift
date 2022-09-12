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

    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

public struct VideoView: UIViewRepresentable {
    let player: Player?
    let backgroundColor: Color

    public init(player: Player?, backgroundColor: Color = .black) {
        self.player = player
        self.backgroundColor = backgroundColor
    }

    public func makeUIView(context: Context) -> VideoLayerView {
        let view = VideoLayerView()
        if let backgroundColor = backgroundColor.cgColor {
            view.backgroundColor = UIColor(cgColor: backgroundColor)
        }
        view.player = player?.rawPlayer
        return view
    }

    public func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player?.rawPlayer
    }
}
