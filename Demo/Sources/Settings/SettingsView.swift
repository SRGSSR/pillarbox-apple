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

private struct InfoCell: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
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

    private var applicationIdentifier: String? {
        let applicationIdentifier = Bundle.main.infoDictionary!["TestFlightApplicationIdentifier"] as! String
        return !applicationIdentifier.isEmpty ? applicationIdentifier : nil
    }

    var body: some View {
        List {
            applicationSection()
            playerSection()
            debuggingSection()
            gitHubSection()
            versionSection()
        }
        .navigationTitle("Settings")
        .tracked(name: "settings")
    }

    private static func testFlightUrl(forApplicationIdentifier applicationIdentifier: String) -> URL? {
        var url = URL("itms-beta://beta.itunes.apple.com/v1/app/")
            .appending(path: applicationIdentifier)
#if os(iOS)
        if !UIApplication.shared.canOpenURL(url) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.scheme = "https"
            url = components.url!
        }
#endif
        return url
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
        }
    }

    @ViewBuilder
    private func versionSection() -> some View {
        Section {
            InfoCell(title: "Application", value: "\(version), build \(buildVersion)")
            InfoCell(title: "Library", value: Player.version)
            if let applicationIdentifier {
                Button("TestFlight builds") {
                    openTestFlight(forApplicationIdentifier: applicationIdentifier)
                }
            }
        } header: {
            Text("Version information")
        } footer: {
            versionFooter()
        }
    }

    @ViewBuilder
    private func versionFooter() -> some View {
        HStack(spacing: 0) {
            Text("Made with ")
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .pulseSymbolEffect()
            Text(" in Switzerland")
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func gitHubSection() -> some View {
#if os(iOS)
        Section("GitHub") {
            Button("Project") { GitHub.open(.project) }
            Button("Source code") { GitHub.open(.apple) }
                .swipeActions {
                    Button("Web") { GitHub.open(.web) }
                        .tint(.yellow)
                    Button("Documentation") { GitHub.open(.documentation) }
                        .tint(.red)
                    Button("Android") { GitHub.open(.android) }
                        .tint(.green)
                }
        }
#else
        self
#endif
    }

    private func simulateMemoryWarning() {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }

    private func openTestFlight(forApplicationIdentifier applicationIdentifier: String?) {
        guard let applicationIdentifier, let url = Self.testFlightUrl(forApplicationIdentifier: applicationIdentifier) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(Router())
}
