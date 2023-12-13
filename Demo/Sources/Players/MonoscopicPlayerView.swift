//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Player
import SceneKit
import SwiftUI

struct MonoscopicPlayerView: View {
    let media: Media

    @StateObject private var player = Player()
    @StateObject private var deviceRotation = DeviceRotation()

    @State private var translation: CGSize = .zero
    @State private var initialTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            MonoscopicVideoView(player: player, orientation: orientation(from: translation, in: geometry))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            translation = CGSize(
                                width: initialTranslation.width + value.translation.width,
                                height: initialTranslation.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            initialTranslation = translation
                        }
                )
        }
        .ignoresSafeArea()
        .onAppear(perform: play)
    }

    private func baseOrientation() -> SCNQuaternion {
        if let attitude = deviceRotation.attitude, let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return Quaternion.cameraOrientationForAttitude(attitude, interfaceOrientation: windowScene.interfaceOrientation)
        }
        else {
            return Quaternion.quaternionWithAngleAndAxis(0, 1, 0, 0)
        }
    }

    private func orientation(from translation: CGSize, in geometry: GeometryProxy) -> SCNQuaternion {
        let wx = .pi / 2 * translation.height / geometry.size.height
        let wy = .pi / 2 * translation.width / geometry.size.width
        return Quaternion.rotate(baseOrientation(), Float(wx), Float(wy))
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }
}

extension MonoscopicPlayerView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    MonoscopicPlayerView(media: Media(from: URLTemplate.gothard_360))
}
