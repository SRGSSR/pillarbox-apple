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

    @AppStorage(UserDefaults.allowsExternalPlaybackSettingKey)
    private var allowsExternalPlaybackSetting = true

    @AppStorage(UserDefaults.audiovisualBackgroundPlaybackPolicySettingKey)
    private var audiovisualBackgroundPlaybackPolicySettingKey: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic

    var body: some View {
        List {
            Toggle("Presenter mode", isOn: $isPresentedModeEnabled)
            Toggle("Allows external playback", isOn: $allowsExternalPlaybackSetting)
            seekBehaviorPicker()
            audiovisualBackgroundPlaybackPolicyPicker()
            Toggle("Body counters", isOn: $areBodyCountersEnabled)
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private func seekBehaviorPicker() -> some View {
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

    @ViewBuilder
    private func audiovisualBackgroundPlaybackPolicyPicker() -> some View {
        Picker("Audiovisual background policy", selection: $audiovisualBackgroundPlaybackPolicySettingKey) {
            Text("Automatic").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.automatic)
            Text("Continues if possible").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.continuesIfPossible)
            Text("Pauses").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.pauses)
        }
#if os(tvOS)
        .pickerStyle(.inline)
#else
        .pickerStyle(.menu)
#endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
