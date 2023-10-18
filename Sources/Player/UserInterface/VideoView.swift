//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
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

/// A view displaying video content provided by an associated player.
/// 
/// Behavior: h-exp, v-exp
public struct VideoView: UIViewRepresentable {
    @ObservedObject private var player: Player

    private let gravity: AVLayerVideoGravity
    private var isEnabledForPictureInPicture = false

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect) {
        self.player = player
        self.gravity = gravity
    }

    public func makeUIView(context: Context) -> VideoLayerView {
        let view = VideoLayerView()
        view.backgroundColor = .clear
        view.player = player.queuePlayer
        return view
    }

    public func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
        if isEnabledForPictureInPicture {
            PictureInPicture.shared.assign(playerLayer: uiView.playerLayer)
        }
    }

    public static func dismantleUIView(_ uiView: VideoLayerView, coordinator: ()) {
        if !PictureInPicture.shared.isActive {
            PictureInPicture.shared.unassign()
        }
    }
}

public extension VideoView {
    func enabledForPictureInPicture(_ enabled: Bool = true) -> Self {
        var view = self
        view.isEnabledForPictureInPicture = enabled
        return view
    }
}
