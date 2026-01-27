//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct SettingsMenu: View {
    @AppStorage(UserDefaults.DemoSettingKey.routePickerSetting.rawValue)
    private var routePickerSetting: RoutePickerSetting = .button

    let player: Player
    let isOverCurrentContext: Bool

    @Binding var isPresentingMetrics: Bool
    @Binding var gravity: AVLayerVideoGravity

    var body: some View {
        SwiftUI.Menu {
            player.standardSettingsMenu()
            QualityMenu(player: player)
            if isOverCurrentContext {
                player.zoomMenu(gravity: $gravity)
            }
            metricsMenu()
            if routePickerSetting == .menu {
                player.routePickerMenu()
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 20))
                .tint(.white)
        }
        .menuOrder(.fixed)
        .hoverEffect()
    }

    @ViewBuilder
    private func metricsMenu() -> some View {
        if !isPresentingMetrics {
            Button(action: showMetrics) {
                Label("Metrics", systemImage: "chart.bar")
            }
        }
    }

    private func showMetrics() {
        isPresentingMetrics = true
    }
}
