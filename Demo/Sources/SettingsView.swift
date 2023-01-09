//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey) private var isPresentedModeEnabled = false
    @AppStorage(UserDefaults.bodyCountersEnabledKey) private var areBodyCountersEnabled = false
    @AppStorage(UserDefaults.seekBehaviorSettingKey) private var seekBehaviorSetting: SeekBehaviorSetting = .immediate

    var body: some View {
        List {
            Toggle("Presenter mode", isOn: $isPresentedModeEnabled)
            Toggle("Body counters", isOn: $areBodyCountersEnabled)
            Picker("Seek behavior", selection: $seekBehaviorSetting) {
                Text("Immediate").tag(SeekBehaviorSetting.immediate)
                Text("Deferred").tag(SeekBehaviorSetting.deferred)
            }
#if os(tvOS)
            .pickerStyle(.inline)
#else
            .pickerStyle(.menu)
#endif
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
