//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

struct QualityMenu: View {
    let player: Player

    @AppStorage(UserDefaults.DemoSettingKey.qualitySetting.rawValue)
    private var qualitySetting: QualitySetting = .high

    var body: some View {
        SwiftUI.Menu {
            SwiftUI.Picker(selection: $qualitySetting) {
                ForEach(QualitySetting.allCases, id: \.self) { quality in
                    Text(quality.name).tag(quality)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
        } label: {
            Label("Quality", systemImage: "person.and.background.dotted")
            Text(qualitySetting.name)
        }
    }
}
