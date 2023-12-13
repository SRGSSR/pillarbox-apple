//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// Behavior: h-exp, v-hug
private struct TextFieldView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Enter URL or URN", text: $text)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .autocorrectionDisabled()

            HStack(spacing: 0) {
                Button(action: clear) {
                    Image(systemName: "xmark.circle.fill")
                }
                .tint(.white)
                .opacity(text.isEmpty ? 0 : 1)
#if os(iOS)
                PasteButton(payloadType: URL.self) { url in
                    text = url.first?.absoluteString ?? ""
                }
                .labelStyle(.iconOnly)
                .scaleEffect(x: 0.5, y: 0.5)
#endif
            }
        }
    }

    private func clear() {
        text = ""
    }
}

private struct MediaEntryView: View {
    @State private var text = ""
    @EnvironmentObject private var router: Router

    private var media: Media {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedText.hasPrefix("urn") {
            return .init(title: "URN", type: .urn(trimmedText))
        }
        else if let url = URL(string: trimmedText) {
            return .init(title: "URL", type: .url(url))
        }
        else {
            return .init(from: URLTemplate.unknown)
        }
    }

    var body: some View {
        VStack {
            TextFieldView(text: $text)
            if !text.isEmpty {
                Button(action: play) {
                    Text("Play")
                }
                .foregroundColor(Color.accentColor)
            }
        }
        .buttonStyle(.plain)
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
                .padding(.horizontal, constant(iOS: 0, tvOS: 50))
        }
#if os(iOS)
        .navigationTitle("Examples")
        .refreshable { await model.refresh() }
#endif
    }

    @ViewBuilder
    private func content() -> some View {
        Group {
            MediaEntryView()
            srgSections()
            thirdPartySections()
            miscellaneousSections()
        }
        .scrollDismissesKeyboard(.immediately)
        .animation(.defaultLinear, value: model.protectedMedias)
        .tracked(name: "examples")
    }

    @ViewBuilder
    private func srgSections() -> some View {
        section(title: "SRG SSR streams (URLs)", medias: model.urlMedias)
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
        section(title: "Unified Streaming", medias: model.unifiedStreamingSourceMedias)
    }

    @ViewBuilder
    private func miscellaneousSections() -> some View {
        section(title: "Aspect ratios", medias: model.aspectRatioMedias)
        section(title: "Unbuffered streams", medias: model.unbufferedMedias)
        section(title: "Corner cases", medias: model.cornerCaseMedias)
    }

    @ViewBuilder
    private func section(title: String, medias: [Media]) -> some View {
        CustomSection(title: title) {
            ForEach(medias, id: \.self) { media in
                Cell(title: media.title, subtitle: media.description) {
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
