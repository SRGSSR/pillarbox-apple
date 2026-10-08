//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

private struct TextFieldView: View {
    private let placeholder: String
    @Binding private var text: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()
#if os(iOS)
            HStack(spacing: 0) {
                Button(action: clear) {
                    Image(systemName: "xmark.circle.fill")
                }
                .tint(.white)
                .opacity(text.isEmpty ? 0 : 1)

                PasteButton(payloadType: URL.self) { url in
                    text = url.first?.absoluteString ?? ""
                }
                .labelStyle(.iconOnly)
                .scaleEffect(x: 0.5, y: 0.5)
            }
#endif
        }
    }

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    private func clear() {
        text = ""
    }
}

private struct MediaEntryView: View {
    private enum Kind: CaseIterable, CustomLocalizedStringResourceConvertible {
        case url
        case tokenProtected
        case encrypted
        case productionUrn
        case stageUrn
        case testUrn
        case productionDemo
        case developmentDemo

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .url:
                return "URL"
            case .tokenProtected:
                return "URL with SRG SSR token protection"
            case .encrypted:
                return "URL with SRG SSR DRM encryption"
            case .productionUrn:
                return "URN (Production)"
            case .stageUrn:
                return "URN (Stage)"
            case .testUrn:
                return "URN (Test)"
            case .productionDemo:
                return "Demo (Production)"
            case .developmentDemo:
                return "Demo (Development)"
            }
        }
    }

    @State private var kind: Kind = .url
    @State private var text = ""
    @State private var certificateUrlString = ""
    @EnvironmentObject private var router: Router

#if DOWNLOADS && os(iOS)
    @EnvironmentObject private var downloader: DemoDownloader
#endif

    private var media: Media {
        switch kind {
        case .url:
            guard let url else { return URLMedia.unknown }
            return .init(title: "URL", subtitle: url.absoluteString, kind: .url(url))
        case .tokenProtected:
            guard let url else { return URLMedia.unknown }
            return .init(title: "Token-protected", subtitle: url.absoluteString, kind: .url(url, protection: .token))
        case .encrypted:
            guard let url, let certificateUrl else { return URLMedia.unknown }
            return .init(title: "Encrypted", subtitle: url.absoluteString, kind: .url(url, protection: .fairPlay(certificateUrl: certificateUrl)))
        case .productionUrn:
            return .init(title: trimmedText, kind: .urn(trimmedText, serverSetting: .production))
        case .stageUrn:
            return .init(title: trimmedText, kind: .urn(trimmedText, serverSetting: .stage))
        case .testUrn:
            return .init(title: trimmedText, kind: .urn(trimmedText, serverSetting: .test))
        case .productionDemo:
            return .init(title: trimmedText, kind: .demo(trimmedText, isProduction: true))
        case .developmentDemo:
            return .init(title: trimmedText, kind: .demo(trimmedText, isProduction: false))
        }
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var url: URL? {
        URL(string: trimmedText)
    }

    private var certificateUrl: URL? {
        URL(string: certificateUrlString.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var textPlaceholder: String {
        switch kind {
        case .productionUrn, .stageUrn, .testUrn:
            return "URN"
        case .productionDemo, .developmentDemo:
            return "Identifier"
        default:
            return "URL"
        }
    }

    private var isValid: Bool {
        switch kind {
        case .productionUrn, .stageUrn, .testUrn:
            return !text.isEmpty
        case .encrypted:
            return url != nil && certificateUrl != nil
        default:
            return url != nil
        }
    }

    var body: some View {
        VStack {
            kindPicker()
            TextFieldView(textPlaceholder, text: $text)
            if kind == .encrypted {
                TextFieldView("Certificate URL", text: $certificateUrlString)
            }
            if isValid {
                actionButtons()
            }
        }
        .transaction { $0.animation = nil }
        .buttonStyle(.plain)
        .padding(constant(iOS: 0, tvOS: 30))
    }

    private func kindPicker() -> some View {
        PickerMenu("Kind", selection: $kind) {
            ForEach(Kind.allCases, id: \.self) { kind in
                Text(kind.localizedStringResource).tag(kind)
            }
        }
    }

    private func actionButtons() -> some View {
        HStack {
            Button(action: play) {
                Text("Play")
                    .frame(maxWidth: .infinity)
            }
#if DOWNLOADS && os(iOS)
            Button(action: download) {
                Text("Download")
                    .frame(maxWidth: .infinity)
            }
#endif
        }
        .foregroundColor(Color.accentColor)
    }

    private func play() {
        router.presented = .player(media: media)
    }

#if DOWNLOADS && os(iOS)
    private func download() {
        downloader.addDownload(media: media)
    }
#endif
}

struct ExamplesView: View {
    @StateObject private var model = ExamplesViewModel()
    @EnvironmentObject private var router: Router

    var body: some View {
        CustomList {
            content()
        }
        .scrollDismissesKeyboard(.immediately)
        .animation(.defaultLinear, value: model.protectedMedias)
        .tracked(name: "examples")
#if os(iOS)
        .navigationTitle("Examples")
        .refreshable { await model.refresh() }
#else
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }

    @ContentBuilder
    private func content() -> some View {
        MediaEntryView()
        srgSections()
        thirdPartySections()
        miscellaneousSections()
    }

    @ContentBuilder
    private func srgSections() -> some View {
        section(title: "Various streams (URLs)", medias: model.urlMedias)
        section(title: "SRG SSR streams (URNs)", medias: model.urnMedias)
        if !model.protectedMedias.isEmpty {
            section(title: "Protected streams (URNs)", medias: model.protectedMedias)
        }
    }

    @ContentBuilder
    private func thirdPartySections() -> some View {
        section(title: "Apple streams", medias: model.appleMedias)
        section(title: "Third-party streams", medias: model.thirdPartyMedias)
        section(title: "Unified Streaming streams", medias: model.unifiedStreamingMedias)
        section(title: "BBC Test Card streams", medias: model.bbcTestCardMedias)
        section(title: "Mux streams", medias: model.muxMedias)
    }

    @ContentBuilder
    private func miscellaneousSections() -> some View {
        section(title: "Time ranges", medias: model.timeRangesMedias)
        section(title: "Aspect ratios", medias: model.aspectRatioMedias)
#if os(iOS)
        section(title: "360° videos", medias: model.threeSixtyMedias)
#endif
        section(title: "Unbuffered streams", medias: model.unbufferedMedias)
        section(title: "Corner cases", medias: model.cornerCaseMedias)
    }

    private func section(title: LocalizedStringResource, medias: [Media]) -> some View {
        CustomSection(title) {
            ForEach(medias, id: \.self) { media in
                Cell(title: media.title, subtitle: media.subtitle, imageUrl: media.imageUrl) {
                    router.presented = .player(media: media)
                }
#if DOWNLOADS && os(iOS)
                .swipeActions {
                    DownloadAction(media: media)
                }
#endif
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExamplesView()
    }
    .environmentObject(Router())
}
