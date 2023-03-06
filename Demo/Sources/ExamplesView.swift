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
        if !text.hasPrefix("urn"), let url = URL(string: text) {
            return .init(title: "URL", type: .url(url))
        }
        else {
            return .init(title: "URN", type: .urn(text))
        }
    }

    var body: some View {
        VStack {
            TextFieldView(text: $text)
            Button(action: play) {
                Text("Play")
            }
            .sheet(isPresented: $isPresented) {
                PlayerView(media: media)
            }
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
                .buttonStyle(.plain)
            section(title: "SRG SSR streams (URLs)", medias: model.urlMedias)
            section(title: "SRG SSR streams (URNs)", medias: model.urnMedias)
            if !model.protectedMedias.isEmpty {
                section(title: "Protected streams (URNs)", medias: model.protectedMedias)
            }
            section(title: "Apple streams", medias: model.appleMedias)
            section(title: "Aspect ratios", medias: model.aspectRatioMedias)
            section(title: "Unbuffered streams", medias: model.unbufferedMedias)
            section(title: "Corner cases", medias: model.cornerCaseMedias)
        }
        .animation(.linear(duration: 0.2), value: model.protectedMedias)
        .navigationTitle("Examples")
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
