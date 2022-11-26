//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey) private var isPresentedModeEnabled = false
    @AppStorage(UserDefaults.bodyCountersEnabledKey) private var areBodyCountersEnabled = false

    var body: some View {
        List {
            Toggle("Presenter mode", isOn: $isPresentedModeEnabled)
            Toggle("Body counters", isOn: $areBodyCountersEnabled)
        }
        .navigationTitle("Settings")
    }
}

// MARK: Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
