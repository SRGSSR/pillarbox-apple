//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// MARK: View

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey) private var isEnabled = false

    var body: some View {
        List {
            Toggle("Presenter mode", isOn: $isEnabled)
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
