//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SceneKit
import SpriteKit
import SwiftUI

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct MonoscopicVideoView: View {
    let player: Player

    public var body: some View {
        _MonoscopicVideoView(player: player)
    }

    public init(player: Player) {
        self.player = player
    }
}

private struct _MonoscopicVideoView: UIViewRepresentable {
    @ObservedObject var player: Player

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var player: Player?
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isPlaying = true
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard player != context.coordinator.player, let presentationSize = player.presentationSize else { return }
        context.coordinator.player = player
        uiView.scene = scene(for: player.systemPlayer, presentationSize: presentationSize)
    }

    private func scene(for player: AVPlayer, presentationSize: CGSize) -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(cameraNode())
        scene.rootNode.addChildNode(videoSphereNode(for: player, presentationSize: presentationSize))
        return scene
    }

    private func cameraNode() -> SCNNode {
        let node = SCNNode()
        node.camera = .init()
        node.position = SCNVector3Zero
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
        return sphereNode
    }
}
