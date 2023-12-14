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
    class Coordinator {
        var player: Player?
        var cameraNode: SCNNode?
    }

    static let presentationSize = CGSize(width: 4096, height: 2048)

    @ObservedObject var player: Player
    let orientation: SCNQuaternion

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
        if player != context.coordinator.player {
            context.coordinator.player = player
            uiView.scene = scene(for: player.systemPlayer, context: context)
        }
        context.coordinator.cameraNode?.orientation = orientation
    }

    private func scene(for player: AVPlayer, context: Context) -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(cameraNode(context: context))
        scene.rootNode.addChildNode(videoSphereNode(for: player))
        return scene
    }

    private func cameraNode(context: Context) -> SCNNode {
        let node = SCNNode()
        node.camera = .init()
        node.position = SCNVector3Zero
        context.coordinator.cameraNode = node
        return node
    }

    private func videoTextureNode(for player: AVPlayer) -> SKNode {
        let node = SKVideoNode(avPlayer: player)
        node.size = Self.presentationSize
        node.position = CGPoint(x: Self.presentationSize.width / 2, y: Self.presentationSize.height / 2)
        return node
    }

    private func videoScene(for player: AVPlayer) -> SKScene? {
        let scene = SKScene(size: Self.presentationSize)
        scene.backgroundColor = .clear
        scene.addChild(videoTextureNode(for: player))
        return scene
    }

    private func videoSphere(for player: AVPlayer) -> SCNSphere {
        // Avoid small radii (< 5) and large ones (> 100), for which the result is incorrect. Anything in between seems fine.
        let sphere = SCNSphere(radius: 20)
        if let firstMaterial = sphere.firstMaterial {
            firstMaterial.isDoubleSided = true
            firstMaterial.diffuse.contents = videoScene(for: player)
        }
        return sphere
    }

    private func videoSphereNode(for player: AVPlayer) -> SCNNode {
        let sphereNode = SCNNode(geometry: videoSphere(for: player))
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

    /// Creates a view displaying video content.
    ///
    /// - Parameters:
    ///   - player: The player whose content is displayed.
    ///   - orientation: The orientation at which the content is seen.
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
