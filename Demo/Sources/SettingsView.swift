//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey)
    private var isPresenterModeEnabled = false

    @AppStorage(UserDefaults.bodyCountersEnabledKey)
    private var areBodyCountersEnabled = false

    @AppStorage(UserDefaults.playerLayoutKey)
    private var playerLayout: PlayerLayout = .custom

    @AppStorage(UserDefaults.allowsExternalPlaybackKey)
    private var allowsExternalPlayback = true

    @AppStorage(UserDefaults.smartNavigationEnabledKey)
    private var isSmartNavigationEnabled = true

    @AppStorage(UserDefaults.seekBehaviorSettingKey)
    private var seekBehaviorSetting: SeekBehaviorSetting = .immediate

    @AppStorage(UserDefaults.audiovisualBackgroundPlaybackPolicyKey)
    private var audiovisualBackgroundPlaybackPolicyKey: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic

    private var version: String {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }

    private var buildVersion: String {
        Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    }

    var body: some View {
        List {
            applicationSection()
            playerSection()
            debuggingSection()
        }
        .navigationTitle("Settings")
    }

    @ViewBuilder
    private func applicationSection() -> some View {
        Section("Application") {
            Toggle(isOn: $isPresenterModeEnabled) {
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
    private func playerSection() -> some View {
        Section("Player") {
            playerLayoutPicker()
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
    private func playerLayoutPicker() -> some View {
        Picker("Player layout", selection: $playerLayout) {
            Text("Custom").tag(PlayerLayout.custom)
            Text("System").tag(PlayerLayout.system)
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

    @ViewBuilder
    private func debuggingSection() -> some View {
        Section {
            Button("Simulate memory warning", action: simulateMemoryWarning)
            Button("Clear URL cache", action: clearUrlCache)
        } header: {
            Text("Debugging")
        } footer: {
            debuggingFooter()
        }
    }

    @ViewBuilder
    private func debuggingFooter() -> some View {
        HStack {
            Text("Version \(version) Build \(buildVersion)")
        }
        .frame(maxWidth: .infinity)
    }

    private func simulateMemoryWarning() {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }

    private func clearUrlCache() {
        URLCache.shared.removeAllCachedResponses()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
