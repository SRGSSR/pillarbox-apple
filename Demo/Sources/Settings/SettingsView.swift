//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

private struct UrlCacheView: View {
    @State private var urlCacheSize: String = ""

    var body: some View {
        HStack {
            Button("Clear URL cache", action: clearUrlCache)
#if os(iOS)
                .buttonStyle(.borderless)
#endif
            Spacer()
            Text(urlCacheSize)
                .font(.footnote)
                .foregroundColor(.red)
        }
        .onAppear {
            updateCacheSize()
        }
    }

    private func updateCacheSize() {
        urlCacheSize = ByteCountFormatter.string(fromByteCount: Int64(URLCache.shared.currentDiskUsage), countStyle: .binary)
    }

    private func clearUrlCache() {
        URLCache.shared.removeAllCachedResponses()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            updateCacheSize()
        }
    }
}

struct SettingsView: View {
    @AppStorage(UserDefaults.presenterModeEnabledKey)
    private var isPresenterModeEnabled = false

#if os(iOS)
    @AppStorage(UserDefaults.playerLayoutKey)
    private var playerLayout: PlayerLayout = .custom
#endif

    @AppStorage(UserDefaults.allowsExternalPlaybackKey)
    private var allowsExternalPlayback = true

    @AppStorage(UserDefaults.smartNavigationEnabledKey)
    private var isSmartNavigationEnabled = true

    @AppStorage(UserDefaults.seekBehaviorSettingKey)
    private var seekBehaviorSetting: SeekBehaviorSetting = .immediate

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
        .tracked(name: "settings")
    }

    @ViewBuilder
    private func applicationSection() -> some View {
        Section("Application") {
            Toggle(isOn: $isPresenterModeEnabled) {
                Text("Presenter mode")
                Text("Displays touches for presentation purposes.").font(.footnote)
            }
        }
    }

    @ViewBuilder
    private func playerSection() -> some View {
        Section("Player") {
#if os(iOS)
            playerLayoutPicker()
#endif
            Toggle("Allows external playback", isOn: $allowsExternalPlayback)
            Toggle(isOn: $isSmartNavigationEnabled) {
                Text("Smart navigation")
                Text("Improves playlist navigation so that it feels more natural.").font(.footnote)
            }
            seekBehaviorPicker()
        }
    }

#if os(iOS)
    @ViewBuilder
    private func playerLayoutPicker() -> some View {
        Picker("Layout", selection: $playerLayout) {
            Text("Custom").tag(PlayerLayout.custom)
            Text("System").tag(PlayerLayout.system)
        }
    }
#endif

    @ViewBuilder
    private func seekBehaviorPicker() -> some View {
        Picker("Seek behavior", selection: $seekBehaviorSetting) {
            Text("Immediate").tag(SeekBehaviorSetting.immediate)
            Text("Deferred").tag(SeekBehaviorSetting.deferred)
        }
    }

    @ViewBuilder
    private func debuggingSection() -> some View {
        Section {
            Button("Simulate memory warning", action: simulateMemoryWarning)
            UrlCacheView()
        } header: {
            Text("Debugging")
        } footer: {
            debuggingFooter()
        }
    }

    @ViewBuilder
    private func debuggingFooter() -> some View {
        VStack {
            Text("Version \(version) Build \(buildVersion), Player \(Player.version)")
            HStack(spacing: 0) {
                Text("Made with ")
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .pulseSymbolEffect()
                Text(" in Switzerland")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func simulateMemoryWarning() {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(Router())
}
