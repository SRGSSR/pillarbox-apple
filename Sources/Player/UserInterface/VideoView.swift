//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UIKit

private final class VideoLayerView: UIView {
    let playerLayer: AVPlayerLayer

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    init(from playerLayer: AVPlayerLayer? = nil) {
        self.playerLayer = playerLayer ?? .init()
        super.init(frame: .zero)
        layer.addSublayer(self.playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.synchronizeAnimations {
            playerLayer.frame = layer.bounds
        }
    }
}

private struct _PictureInPictureSupportingVideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity
    let identifier: String

    static func dismantleUIView(_ uiView: VideoLayerView, coordinator: Void) {
        PictureInPicture.shared.unregister(for: uiView.playerLayer)
    }

    func makeUIView(context: Context) -> VideoLayerView {
        let view = VideoLayerView(from: PictureInPicture.shared.playerLayer(for: identifier))
        PictureInPicture.shared.register(for: view.playerLayer, identifier: identifier)
        return view
    }

    func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
    }
}

private struct _VideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    func makeUIView(context: Context) -> VideoLayerView {
        .init()
    }

    func updateUIView(_ uiView: VideoLayerView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
    }
}

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct VideoView: View {
    private let player: Player
    private let gravity: AVLayerVideoGravity
    private let pictureInPictureIdentifier: String?

    public var body: some View {
        if let pictureInPictureIdentifier {
            _PictureInPictureSupportingVideoView(player: player, gravity: gravity, identifier: pictureInPictureIdentifier)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    PictureInPicture.shared.stop()
                }
        }
        else {
            _VideoView(player: player, gravity: gravity)
        }
    }

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect, pictureInPictureIdentifier: String? = nil) {
        self.player = player
        self.gravity = gravity
        self.pictureInPictureIdentifier = pictureInPictureIdentifier
    }
}

private extension CALayer {
    func synchronizeAnimations(_ animations: () -> Void) {
        CATransaction.begin()
        if let positionAnimation = animation(forKey: "position") {
            CATransaction.setAnimationDuration(positionAnimation.duration)
            CATransaction.setAnimationTimingFunction(positionAnimation.timingFunction)
        }
        else {
            CATransaction.disableActions()
        }
        animations()
        CATransaction.commit()
    }
}
