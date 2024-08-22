//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SceneKit
import SwiftUI

/// An interactive that allows navigation of 360° monoscopic videos, either using drag gestures or by changing the
/// device orientation.
struct MonoscopicVideoView: View {
    let player: Player

    @StateObject private var motionManager = MotionManager()
    @State private var translation: CGSize = .zero
    @State private var initialTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            VideoView(player: player)
                .orientation(orientation(from: translation, in: geometry))
                .gesture(
                    // Use non-zero minimum distance to avoid conflicts with single taps.
                    DragGesture(minimumDistance: 1)
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
    }

    private func baseOrientation() -> SCNQuaternion {
        if !ProcessInfo.processInfo.isiOSAppOnMac, let attitude = motionManager.attitude {
            return SCNQuaternionForAttitude(attitude)
        }
        else {
            return .monoscopicDefault
        }
    }

    private func orientation(from translation: CGSize, in geometry: GeometryProxy) -> SCNQuaternion {
        let wx = .pi / 2 * translation.height / geometry.size.height
        let wy = .pi * translation.width / geometry.size.width
        return SCNQuaternionRotate(baseOrientation(), Float(wx), Float(wy))
    }
}
