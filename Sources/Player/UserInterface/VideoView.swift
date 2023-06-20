//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UIKit

private final class VideoLayerUIView: UIView {
    override class var layerClass: AnyClass {
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

private struct VideoLayerView: UIViewRepresentable {
    @ObservedObject private var player: Player

    private let gravity: AVLayerVideoGravity

    init(player: Player, gravity: AVLayerVideoGravity) {
        self.player = player
        self.gravity = gravity
    }

    func makeUIView(context: Context) -> VideoLayerUIView {
        let view = VideoLayerUIView()
        view.backgroundColor = .clear
        view.player = player.queuePlayer
        return view
    }

    func updateUIView(_ uiView: VideoLayerUIView, context: Context) {
        uiView.player = player.queuePlayer
        uiView.playerLayer.videoGravity = gravity
    }
}

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct VideoView: View {
    @ObservedObject private var player: Player

    private let gravity: AVLayerVideoGravity

    public init(player: Player, gravity: AVLayerVideoGravity = .resizeAspect) {
        self.player = player
        self.gravity = gravity
    }

    public var body: some View {
        VideoLayerView(player: player, gravity: gravity)
            .opacity(player.isReadyForDisplay ? 1 : 0)
    }
}
