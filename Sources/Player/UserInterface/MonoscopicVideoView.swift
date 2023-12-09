//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SceneKit
import SpriteKit
import SwiftUI

/// A view displaying video content provided by an associated player.
///
/// Behavior: h-exp, v-exp
public struct MonoscopicVideoView: UIViewRepresentable {
    @ObservedObject private var player: Player

    public class Coordinator: NSObject, SCNSceneRendererDelegate {

    }

    public init(player: Player) {
        self.player = player
    }

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isPlaying = true
        view.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        if let presentationSize = player.presentationSize {
            uiView.scene = scene(with: presentationSize)
        }
        else {
            uiView.scene = nil
        }
    }

    private func scene(with presentationSize: CGSize) -> SCNScene {
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = .init()
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)

        let videoScene = SKScene(size: presentationSize)
        videoScene.backgroundColor = .clear

        let videoNode = SKVideoNode(avPlayer: player.systemPlayer)
        videoNode.size = presentationSize
        videoNode.position = CGPoint(x: presentationSize.width / 2, y: presentationSize.height / 2)
        videoScene.addChild(videoNode)

        // Avoid small radii (< 5) and large ones (> 100), for which the result is incorrect. Anything in between seems fine.
        let sphere = SCNSphere(radius: 20)
        if let firstMaterial = sphere.firstMaterial {
            firstMaterial.isDoubleSided = true
            firstMaterial.diffuse.contents = videoScene
        }

        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(sphereNode)
        return scene
    }
}
