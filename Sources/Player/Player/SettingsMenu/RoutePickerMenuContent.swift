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

    let prioritizesVideoDevices: Bool
    let activeTintColor: Color?
    @ObservedObject var player: Player

    var body: some View {
        RoutePickerButton(prioritizesVideoDevices: prioritizesVideoDevices) {
            Label {
                Text(verbatim: "AirPlay")
            } icon: {
                icon()
            }
        }
    }

    private var foregroundColor: Color {
        activeTintColor ?? Self.defaultActiveTintColor
    }

    @ViewBuilder
    private func icon() -> some View {
        if player.isExternalPlaybackActive {
            Image(systemName: "airplay.video")
                .symbolRenderingMode(.palette)
                .foregroundStyle(foregroundColor, foregroundColor.opacity(0.5))
        }
        else {
            Image(systemName: "airplay.video")
        }
    }
}
