//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-hug
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
    private enum Kind {
        case url
        case tokenProtected
        case encrypted
        case ilProductionUrn
        case ilStageUrn
        case ilTestUrn
        case samProductionUrn
        case samStageUrn
        case samTestUrn
    }

    @State private var kind: Kind = .url
    @State private var text = ""
    @State private var certificateUrlString = ""
    @EnvironmentObject private var router: Router

    private var media: Media {
        switch kind {
        case .url:
            guard let url else { return .init(from: URLTemplate.unknown) }
            return .init(title: "URL", type: .url(url))
        case .tokenProtected:
            guard let url else { return .init(from: URLTemplate.unknown) }
            return .init(title: "Token-protected", type: .tokenProtectedUrl(url))
        case .encrypted:
            guard let url, let certificateUrl else { return .init(from: URLTemplate.unknown) }
            return .init(title: "Encrypted", type: .encryptedUrl(url, certificateUrl: certificateUrl))
        case .ilProductionUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .ilProduction))
        case .ilStageUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .ilStage))
        case .ilTestUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .ilTest))
        case .samProductionUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .samProduction))
        case .samStageUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .samStage))
        case .samTestUrn:
            return .init(title: trimmedText, type: .urn(trimmedText, serverSetting: .samTest))
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
        case .ilProductionUrn, .ilStageUrn, .ilTestUrn, .samProductionUrn, .samStageUrn, .samTestUrn:
            return "URN"
        default:
            return "URL"
        }
    }

    private var isValid: Bool {
        switch kind {
        case .ilProductionUrn, .ilStageUrn, .ilTestUrn, .samProductionUrn, .samStageUrn, .samTestUrn:
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
                Button(action: play) {
                    Text("Play")
                }
                .foregroundColor(Color.accentColor)
            }
        }
        .transaction { $0.animation = nil }
        .buttonStyle(.plain)
        .padding(constant(iOS: 0, tvOS: 30))
    }

    @ViewBuilder
    private func kindPicker() -> some View {
        Picker("Kind", selection: $kind) {
            Text("URL").tag(Kind.url)
            Text("URL with SRG SSR token protection").tag(Kind.tokenProtected)
            Text("URL with SRG SSR DRM encryption").tag(Kind.encrypted)
            Divider()
            Text("URN (IL Production)").tag(Kind.ilProductionUrn)
            Text("URN (IL Stage)").tag(Kind.ilStageUrn)
            Text("URN (IL Test)").tag(Kind.ilTestUrn)
            Divider()
            Text("URN (SAM Production)").tag(Kind.samProductionUrn)
            Text("URN (SAM Stage)").tag(Kind.samStageUrn)
            Text("URN (SAM Test)").tag(Kind.samTestUrn)
        }
#if os(tvOS)
        .pickerStyle(.navigationLink)
#endif
    }

    private func play() {
        router.presented = .player(media: media)
    }
}

// Behavior: h-exp, v-exp
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

    @ViewBuilder
    private func content() -> some View {
        MediaEntryView()
        srgSections()
        thirdPartySections()
        miscellaneousSections()
    }

    @ViewBuilder
    private func srgSections() -> some View {
        section(title: "Various streams (URLs)", medias: model.urlMedias)
        section(title: "SRG SSR streams (URNs)", medias: model.urnMedias)
        if !model.protectedMedias.isEmpty {
            section(title: "Protected streams (URNs)", medias: model.protectedMedias)
        }
    }

    @ViewBuilder
    private func thirdPartySections() -> some View {
        section(title: "Apple streams", medias: model.appleMedias)
        section(title: "Third-party streams", medias: model.thirdPartyMedias)
        section(title: "Bitmovin streams streams", medias: model.bitmovinMedias)
        section(title: "Unified Streaming", medias: model.unifiedStreamingMedias)
        section(title: "BBC Test Card", medias: model.bbcTestCardMedias)
    }

    @ViewBuilder
    private func miscellaneousSections() -> some View {
        section(title: "Time ranges", medias: model.timeRangesMedias)
        section(title: "Aspect ratios", medias: model.aspectRatioMedias)
        section(title: "360° videos", medias: model.threeSixtyMedias)
        section(title: "Unbuffered streams", medias: model.unbufferedMedias)
        section(title: "Corner cases", medias: model.cornerCaseMedias)
    }

    @ViewBuilder
    private func section(title: String, medias: [Media]) -> some View {
        CustomSection(title) {
            ForEach(medias, id: \.self) { media in
                Cell(title: media.title, subtitle: media.subtitle, imageUrl: media.imageUrl) {
                    router.presented = .player(media: media)
                }
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
