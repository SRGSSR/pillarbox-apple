//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

// Behavior: h-exp, v-exp
private struct LoadedView: View {
    @ObservedObject var model: ContentListViewModel
    let contents: [ContentListViewModel.Content]
    @State private var isPresented = false

    var body: some View {
        List(contents, id: \.self) { content in
            ContentCell(content: content)
                .onAppear {
                    if let index = contents.firstIndex(of: content), contents.count - index < kPageSize {
                        model.loadMore()
                    }
                }
        }
        .toolbar(content: toolbar)
        .sheet(isPresented: $isPresented, content: playlist)
        .refreshable { await model.refresh() }
    }

    private func openPlaylist() {
        isPresented.toggle()
    }

    private func templates() -> [Template] {
        contents.compactMap { content -> Template? in
            guard case let .media(media) = content else { return nil }
            return Template(title: media.title, type: .urn(media.urn))
        }
    }

    @ViewBuilder
    private func playlist() -> some View {
        PlaylistView(templates: Array(templates().prefix(20)))
    }

    @ViewBuilder
    private func toolbar() -> some View {
        Button(action: openPlaylist) {
            Image(systemName: "rectangle.stack.badge.play")
        }
        .opacity(templates().isEmpty ? 0 : 1)
    }
}

// Behavior: h-hug, v-exp
private struct ContentCell: View {
    let content: ContentListViewModel.Content

    var body: some View {
        switch content {
        case let .topic(topic):
            NavigationLink(topic.title) {
                ContentListView(configuration: .init(kind: .latestMediasForTopic(topic), vendor: topic.vendor))
            }
#if os(iOS)
            .swipeActions { Self.copyButton(text: topic.urn) }
#endif
        case let .media(media):
            Cell(title: media.title, subtitle: media.show?.title, style: Self.style(for: media)) {
                PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
            }
#if os(iOS)
            .swipeActions { Self.copyButton(text: media.urn) }
#endif
        case let .show(show):
            NavigationLink(show.title) {
                ContentListView(configuration: .init(kind: .latestMediasForShow(show), vendor: show.vendor))
            }
#if os(iOS)
            .swipeActions { Self.copyButton(text: show.urn) }
#endif
        }
    }

#if os(iOS)
    @ViewBuilder
    private static func copyButton(text: String) -> some View {
        Button {
            UIPasteboard.general.string = text
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .tint(.accentColor)
    }
#endif

    private static func style(for media: SRGMedia) -> CellStyle {
        media.timeAvailability(at: Date()) == .available ? .standard : .disabled
    }
}

// Behavior: h-exp, v-exp
private struct MessageView: View {
    @ObservedObject var model: ContentListViewModel
    let message: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
    }
}

// Behavior: h-exp, v-exp
struct ContentListView: View {
    let configuration: ContentListViewModel.Configuration
    @StateObject private var model = ContentListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(contents: contents) where contents.isEmpty:
                MessageView(model: model, message: "No content.")
            case let .loaded(contents: contents):
                LoadedView(model: model, contents: contents)
            case let .failed(error):
                MessageView(model: model, message: error.localizedDescription)
            }
        }
        .onAppear { model.configuration = configuration }
        .navigationTitle(configuration.kind.name)
    }
}

struct ContentListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentListView(configuration: .init(kind: .tvLatestMedias, vendor: .RTS))
        }
    }
}
