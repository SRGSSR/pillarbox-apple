//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

private struct UrlCacheView: View {
    @State private var urlCacheSize: String = ""

    var body: some View {
        HStack {
            Button(action: clearUrlCache) {
                HStack {
                    Text("Clear URL cache")
                    Spacer()
                    Text(urlCacheSize)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
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
        CustomList {
            content()
                .padding(.horizontal, constant(iOS: 0, tvOS: 20))
        }
        .tracked(name: "settings")
#if os(iOS)
        .navigationTitle("Settings")
#else
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
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
    private func content() -> some View {
        applicationSection()
        playerSection()
        debuggingSection()
#if os(iOS)
        gitHubSection()
#endif
        versionSection()
    }

    @ViewBuilder
    private func applicationSection() -> some View {
        Section {
            Toggle(isOn: $isPresenterModeEnabled) {
                Text("Presenter mode")
                Text("Displays touches for presentation purposes.").font(.footnote)
            }
        } header: {
            Text("Application")
                .headerStyle()
        }
    }

    @ViewBuilder
    private func playerSection() -> some View {
        Section {
            Toggle(isOn: $isSmartNavigationEnabled) {
                Text("Smart navigation")
                Text("Improves playlist navigation so that it feels more natural.").font(.footnote)
            }
            seekBehaviorPicker()
        } header: {
             Text("Player")
                .headerStyle()
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
    private func debuggingSection() -> some View {
        Section {
            Button(action: simulateMemoryWarning) {
                Text("Simulate memory warning")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            UrlCacheView()
        } header: {
            Text("Debugging")
                .headerStyle()
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
                .headerStyle()
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
#if os(tvOS)
        .focusable()
#endif
    }

#if os(iOS)
    @ViewBuilder
    private func gitHubSection() -> some View {
        Section("GitHub") {
            Button("Project") { GitHub.open(.project) }
            Button("Source code") { GitHub.open(.apple) }
                .swipeActions {
                    Button("Web") { GitHub.open(.web) }
                        .tint(.purple)
                    Button("Documentation") { GitHub.open(.documentation) }
                        .tint(.red)
                    Button("Android") { GitHub.open(.android) }
                        .tint(.green)
                }
        }
    }
#endif

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
