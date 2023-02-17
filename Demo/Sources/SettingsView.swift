//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey)
    private var isPresentedModeEnabled = false

    @AppStorage(UserDefaults.bodyCountersEnabledKey)
    private var areBodyCountersEnabled = false

    @AppStorage(UserDefaults.seekBehaviorSettingKey)
    private var seekBehaviorSetting: SeekBehaviorSetting = .immediate

    @AppStorage(UserDefaults.allowsExternalPlaybackKey)
    private var allowsExternalPlayback = true

    @AppStorage(UserDefaults.smartNavigationEnabledKey)
    private var isSmartNavigationEnabled = true

    @AppStorage(UserDefaults.audiovisualBackgroundPlaybackPolicyKey)
    private var audiovisualBackgroundPlaybackPolicyKey: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic

    var body: some View {
        List {
            applicationSection()
            playerSection()
            debuggingSection()
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private func playerSection() -> some View {
        Section("Player") {
            Toggle("Allows external playback", isOn: $allowsExternalPlayback)
            Toggle(isOn: $isSmartNavigationEnabled) {
                Text("Smart navigation")
                Text("Improves playlist navigation so that it feels more natural.").font(.footnote)
            }
            seekBehaviorPicker()
            audiovisualBackgroundPlaybackPolicyPicker()
        }
    }

    @ViewBuilder
    private func applicationSection() -> some View {
        Section("Application") {
            Toggle(isOn: $isPresentedModeEnabled) {
                Text("Presenter mode")
                Text("Displays touches for presentation purposes.").font(.footnote)
            }
            Toggle(isOn: $areBodyCountersEnabled) {
                Text("Body counters")
                Text("Displays how often some views are refreshed.").font(.footnote)
            }
        }
    }

    @ViewBuilder
    private func debuggingSection() -> some View {
        Section("Debugging") {
            Button("Simulate memory warning", action: simulateMemoryWarning)
        }
    }

    @ViewBuilder
    private func seekBehaviorPicker() -> some View {
        Picker("Seek behavior", selection: $seekBehaviorSetting) {
            Text("Immediate").tag(SeekBehaviorSetting.immediate)
            Text("Deferred").tag(SeekBehaviorSetting.deferred)
        }
    }

    @ViewBuilder
    private func audiovisualBackgroundPlaybackPolicyPicker() -> some View {
        Picker("Audiovisual background policy", selection: $audiovisualBackgroundPlaybackPolicyKey) {
            Text("Automatic").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.automatic)
            Text("Continues if possible").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.continuesIfPossible)
            Text("Pauses").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.pauses)
        }
    }

    private func simulateMemoryWarning() {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
