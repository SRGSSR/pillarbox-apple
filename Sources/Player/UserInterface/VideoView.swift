//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UIKit

public final class VideoLayerView: UIView {
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

    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = layer.bounds
        playerLayer.removeAllAnimations()
    }
}

private struct _VideoView: UIViewRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity
    let supportsPictureInPicture: Bool

    static func dismantleUIView(_ uiView: VideoLayerView, coordinator: Void) {
        guard uiView.playerLayer == PictureInPicture.shared.playerLayer else { return }
        PictureInPicture.shared.playerLayer = nil
    }

    func makeUIView(context: Context) -> VideoLayerView {
        if supportsPictureInPicture {
            let playerLayer = PictureInPicture.shared.playerLayer
            let view = VideoLayerView(from: playerLayer)
            PictureInPicture.shared.playerLayer = playerLayer
            return view
        }
        else {
            return VideoLayerView()
        }
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
    private let supportsPictureInPicture: Bool

    public var body: some View {
        _VideoView(player: player, gravity: gravity, supportsPictureInPicture: supportsPictureInPicture)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                PictureInPicture.shared.stop()
            }
    }

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect, supportsPictureInPicture: Bool = false) {
        self.player = player
        self.gravity = gravity
        self.supportsPictureInPicture = supportsPictureInPicture
    }
}
