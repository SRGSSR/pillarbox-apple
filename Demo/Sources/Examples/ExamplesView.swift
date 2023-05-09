//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
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
            Button(action: clear) {
                Image(systemName: "xmark.circle.fill")
            }
            .tint(.white)
            .opacity(text.isEmpty ? 0 : 1)
        }
    }

    private func clear() {
        text = ""
    }
}

private struct MediaEntryView: View {
    @State private var text = ""
    @State private var isPresented = false

    private var media: Media {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.hasPrefix("urn"), let url = URL(string: trimmedText) {
            return .init(title: "URL", type: .url(url))
        }
        else {
            return .init(title: "URN", type: .urn(trimmedText))
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
        .sheet(isPresented: $isPresented) {
            PlayerView(media: media)
        }
    }

    private func play() {
        isPresented.toggle()
    }
}

// Behavior: h-exp, v-exp
struct ExamplesView: View {
    @StateObject private var model = ExamplesViewModel()

    var body: some View {
        List {
            MediaEntryView()
            section(title: "SRG SSR streams (URLs)", medias: model.urlMedias)
            section(title: "SRG SSR streams (URNs)", medias: model.urnMedias)
            if !model.protectedMedias.isEmpty {
                section(title: "Protected streams (URNs)", medias: model.protectedMedias)
            }
            section(title: "Apple streams", medias: model.appleMedias)
            section(title: "Third-party streams", medias: model.thirdPartyMedias)
            section(title: "Aspect ratios", medias: model.aspectRatioMedias)
            section(title: "Unbuffered streams", medias: model.unbufferedMedias)
            section(title: "Corner cases", medias: model.cornerCaseMedias)
        }
        .scrollDismissesKeyboard(.immediately)
        .animation(.defaultLinear, value: model.protectedMedias)
        .navigationTitle("Examples")
        .tracked(title: "Examples")
        .refreshable { await model.refresh() }
    }

    @ViewBuilder
    private func section(title: String, medias: [Media]) -> some View {
        Section(title) {
            ForEach(medias) { media in
                Cell(title: media.title, subtitle: media.description) {
                    PlayerView(media: media)
                }
            }
        }
    }
}

struct ExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExamplesView()
        }
    }
}
