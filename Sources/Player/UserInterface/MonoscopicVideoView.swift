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

    struct SceneProperties {
        let scene: SCNScene
        let cameraNode: SCNNode
    }

    @ObservedObject var player: Player
    let orientation: SCNQuaternion

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        uiView.scene = nil
        
        if let player = coordinator.player {
            DisplaySleep.shared.allow(for: player)
        }
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func makeUIView(context: Context) -> SCNView {
        DisplaySleep.shared.prevent(for: player)
        let view = SCNView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if player != context.coordinator.player {
            let sceneProperties = Self.scene(for: player)
            uiView.scene = sceneProperties.scene
            context.coordinator.player = player
            context.coordinator.cameraNode = sceneProperties.cameraNode
        }
        context.coordinator.cameraNode?.orientation = orientation
    }
}

/// A view able to display 360° monoscopic video content provided by an associated player.
///
/// The video is projected onto a sphere with the viewer at its center. A quaternion makes it possible to control the
/// orientation at which the content is seen.
///
/// Behavior: h-exp, v-exp
struct MonoscopicVideoView: View {
    private let player: Player
    private let orientation: SCNQuaternion

    var body: some View {
        _MonoscopicVideoView(player: player, orientation: orientation)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                pauseIfNeeded()
            }
    }

    /// Creates a view displaying video content.
    ///
    /// - Parameters:
    ///   - player: The player whose content is displayed.
    ///   - orientation: The orientation at which the content is seen. Use `.monoscopicDefault` to face the content
    ///     without head-tilting.
    init(player: Player, orientation: SCNQuaternion) {
        self.player = player
        self.orientation = orientation
    }

    private func pauseIfNeeded() {
        // `SKVideoNode` does not apply background playback policies. We must apply them manually.
        guard player.audiovisualBackgroundPlaybackPolicy != .continuesIfPossible else { return }
        player.pause()
    }
}

private extension _MonoscopicVideoView {
    // Picking a sufficiently large 2:1 resolution is enough for a sharp image (the actual resolution of course
    // also depends on the content resolution itself). There is therefore no need to fetch the actual content
    // resolution, which would lead to unnecessary complications.
    private static let presentationSize = CGSize(width: 4096, height: 2048)

    static func scene(for player: Player) -> SceneProperties {
        let scene = SCNScene()
        let cameraNode = cameraNode()
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(videoSphereNode(for: player))
        return .init(scene: scene, cameraNode: cameraNode)
    }

    static func cameraNode() -> SCNNode {
        let node = SCNNode()
        node.camera = .init()
        node.position = SCNVector3Zero
        return node
    }

    static func videoTextureNode(for player: Player) -> SKNode {
        let node = VideoNode(avPlayer: player.systemPlayer)
        node.size = presentationSize
        node.position = CGPoint(x: presentationSize.width / 2, y: presentationSize.height / 2)
        return node
    }

    static func videoScene(for player: Player) -> SKScene? {
        let scene = SKScene(size: presentationSize)
        scene.backgroundColor = .clear
        scene.addChild(videoTextureNode(for: player))
        return scene
    }

    static func videoSphere(for player: Player) -> SCNSphere {
        // Avoid small radii (< 5) and large ones (> 100), for which the result is incorrect. Anything in between seems fine.
        let sphere = SCNSphere(radius: 20)
        if let firstMaterial = sphere.firstMaterial {
            firstMaterial.isDoubleSided = true
            firstMaterial.diffuse.contents = videoScene(for: player)
        }
        return sphere
    }

    static func videoSphereNode(for player: Player) -> SCNNode {
        let sphereNode = SCNNode(geometry: videoSphere(for: player))
        sphereNode.position = SCNVector3Zero
        // Flip the video content so that its correctly seen with the default orientation.
        sphereNode.scale = SCNVector3(x: 1, y: -1, z: -1)
        return sphereNode
    }
}
