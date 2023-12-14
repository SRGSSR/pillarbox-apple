//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SceneKit
import SpriteKit
import SwiftUI

private struct _MonoscopicVideoView: UIViewRepresentable {
    @ObservedObject var player: Player
    let orientation: SCNQuaternion

    class Coordinator {
        var player: Player?
        var cameraNode: SCNNode?
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isPlaying = true
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        defer {
            context.coordinator.cameraNode?.orientation = orientation
        }
        guard player != context.coordinator.player, let presentationSize = player.presentationSize else { return }
        context.coordinator.player = player
        uiView.scene = scene(for: player.systemPlayer, presentationSize: presentationSize, context: context)
    }

    private func scene(for player: AVPlayer, presentationSize: CGSize, context: Context) -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(cameraNode(context: context))
        scene.rootNode.addChildNode(videoSphereNode(for: player, presentationSize: presentationSize))
        return scene
    }

    private func cameraNode(context: Context) -> SCNNode {
        let node = SCNNode()
        node.camera = .init()
        node.position = SCNVector3Zero
        context.coordinator.cameraNode = node
        return node
    }

    private func videoTextureNode(for player: AVPlayer, presentationSize: CGSize) -> SKNode {
        let node = SKVideoNode(avPlayer: player)
        node.size = presentationSize
        node.position = CGPoint(x: presentationSize.width / 2, y: presentationSize.height / 2)
        return node
    }

    private func videoScene(for player: AVPlayer, presentationSize: CGSize) -> SKScene? {
        let scene = SKScene(size: presentationSize)
        scene.backgroundColor = .clear
        scene.addChild(videoTextureNode(for: player, presentationSize: presentationSize))
        return scene
    }

    private func videoSphere(for player: AVPlayer, presentationSize: CGSize) -> SCNSphere {
        // Avoid small radii (< 5) and large ones (> 100), for which the result is incorrect. Anything in between seems fine.
        let sphere = SCNSphere(radius: 20)
        if let firstMaterial = sphere.firstMaterial {
            firstMaterial.isDoubleSided = true
            firstMaterial.diffuse.contents = videoScene(for: player, presentationSize: presentationSize)
        }
        return sphere
    }

    private func videoSphereNode(for player: AVPlayer, presentationSize: CGSize) -> SCNNode {
        let sphereNode = SCNNode(geometry: videoSphere(for: player, presentationSize: presentationSize))
        sphereNode.position = SCNVector3Zero
        // Flip the video content so that its correctly seen with the default orientation.
        sphereNode.scale = SCNVector3(x: 1, y: -1, z: -1)
        return sphereNode
    }
}

/// A view able to display 360° monoscopic video content provided by an associated player.
///
/// The video is projected onto a sphere with the viewer at its center. A quaternion makes it possible to control the
/// orientation at which the content is seen.
///
/// Behavior: h-exp, v-exp
public struct MonoscopicVideoView: View {
    private let player: Player
    private let orientation: SCNQuaternion

    public var body: some View {
        _MonoscopicVideoView(player: player, orientation: orientation)
    }

    public init(player: Player, orientation: SCNQuaternion = .monoscopicDefault) {
        self.player = player
        self.orientation = orientation
    }
}

public extension SCNQuaternion {
    /// The default orientation for monoscopic content.
    ///
    /// Corresponds to a user facing the content with no head tilting.
    static let monoscopicDefault = SCNQuaternionWithAngleAndAxis(0, 1, 0, 0)
}
