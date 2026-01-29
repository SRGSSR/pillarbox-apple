//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct RoutePickerMenuContent: View {
    private static let defaultActiveTintColor: Color = {
        guard let color = AVRoutePickerView().activeTintColor else { return .blue }
        return .init(uiColor: color)
    }()

    let activeTintColor: Color?
    let player: Player

    var body: some View {
        RoutePickerButton(player: player) { isExternalPlaybackActive in
            Label {
                Text(verbatim: "AirPlay")
            } icon: {
                if isExternalPlaybackActive {
                    Image(systemName: "airplay.video")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(foregroundColor, foregroundColor.opacity(0.5))
                }
                else {
                    Image(systemName: "airplay.video")
                }
            }
        }
    }

    private var foregroundColor: Color {
        activeTintColor ?? Self.defaultActiveTintColor
    }
}
