//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

@available(iOS 16.0, tvOS 17.0, *)
struct ZoomMenuContent: View {
    private static let gravities: [AVLayerVideoGravity] = [.resizeAspect, .resizeAspectFill]

    @Binding var gravity: AVLayerVideoGravity
    let action: (AVLayerVideoGravity) -> Void

    @ObservedObject var player: Player

    var body: some View {
        if player.mediaType == .video {
            SwiftUI.Menu {
                SwiftUI.Picker(selection: selection) {
                    ForEach(Self.gravities, id: \.self) { gravity in
                        Self.description(for: gravity).tag(gravity)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } label: {
                Label {
                    Text("Zoom", bundle: .module, comment: "Playback setting menu title")
                } icon: {
                    Image(systemName: imageName)
                }
                Self.description(for: gravity)
            }
        }
    }

    private var selection: Binding<AVLayerVideoGravity> {
        .init {
            gravity
        } set: { newValue in
            gravity = newValue
            action(newValue)
        }
    }

    private var imageName: String {
        if #available(iOS 17, tvOS 17, *) {
            "square.arrowtriangle.4.outward"
        }
        else {
            "rectangle.portrait.arrowtriangle.2.outward"
        }
    }

    private static func description(for gravity: AVLayerVideoGravity) -> Text {
        switch gravity {
        case .resizeAspectFill:
            return Text("Fill", bundle: .module, comment: "Zoom option")
        default:
            return Text("Fit", bundle: .module, comment: "Zoom option")
        }
    }
}
