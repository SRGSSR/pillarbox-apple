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
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private func playerSection() -> some View {
        Section("Player") {
            Toggle("Allows external playback", isOn: $allowsExternalPlayback)
            Toggle("Smart navigation", isOn: $isSmartNavigationEnabled)
            seekBehaviorPicker()
            audiovisualBackgroundPlaybackPolicyPicker()
        }
    }

    @ViewBuilder
    private func applicationSection() -> some View {
        Section("Application") {
            Toggle("Presenter mode", isOn: $isPresentedModeEnabled)
            Toggle("Body counters", isOn: $areBodyCountersEnabled)
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
