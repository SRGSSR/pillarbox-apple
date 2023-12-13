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
    @GestureState private var gestureValue: DragGesture.Value?

    var body: some View {
        GeometryReader { geometry in
            MonoscopicVideoView(player: player, rotation: rotation(from: gestureValue, in: geometry))
                .gesture(
                    DragGesture()
                        .updating($gestureValue) { value, state, _ in
                            state = value
                        }
                )
        }
        .ignoresSafeArea()
        .onAppear(perform: play)
    }

    private func rotation(from gestureValue: DragGesture.Value?, in geometry: GeometryProxy) -> SCNQuaternion {
        if let gestureValue {
            let wx = .pi / 2 * gestureValue.translation.height / geometry.size.height
            let wy = -.pi / 2 * gestureValue.translation.width / geometry.size.width
            return Quaternion.rotate(Quaternion.quaternionWithAngleAndAxis(.pi, 1, 0, 0), Float(wx), Float(wy))
        }
        else {
            return Quaternion.quaternionWithAngleAndAxis(.pi, 1, 0, 0)
        }
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
