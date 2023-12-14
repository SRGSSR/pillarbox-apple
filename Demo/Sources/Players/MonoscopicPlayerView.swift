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
    @StateObject private var motionManager = MotionManager()

    @Environment(\.dismiss) var dismiss

    @State private var translation: CGSize = .zero
    @State private var initialTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
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
                    .ignoresSafeArea()
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "xmark")
                        .tint(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .onAppear(perform: play)
    }

    private func baseOrientation() -> SCNQuaternion {
        if let attitude = motionManager.attitude {
            return SCNQuaternionForAttitude(attitude)
        }
        else {
            return .monoscopicDefault
        }
    }

    private func orientation(from translation: CGSize, in geometry: GeometryProxy) -> SCNQuaternion {
        let wx = .pi / 2 * translation.height / geometry.size.height
        let wy = .pi / 2 * translation.width / geometry.size.width
        return SCNQuaternionRotate(baseOrientation(), Float(wx), Float(wy))
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
