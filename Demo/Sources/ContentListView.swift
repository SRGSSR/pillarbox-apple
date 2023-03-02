//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

private struct LoadedView: View {
    @State private var isPresented = false
    @ObservedObject var model: ContentListViewModel
    let contents: [ContentListViewModel.Content]

    var body: some View {
        List(contents, id: \.self) { content in
            ContentCell(content: content)
                .onAppear {
                    if contents.last == content {
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

    @ViewBuilder
    private func playlist() -> some View {
        let templates = contents.compactMap { content -> Template? in
            guard case let .media(media) = content else { return nil }
            return Template(title: media.title, type: .urn(media.urn))
        }
        PlaylistView(templates: Array(templates.prefix(20)))
    }

    @ViewBuilder
    private func toolbar() -> some View {
        Button(action: openPlaylist) {
            Image(systemName: "rectangle.stack.badge.play")
        }
    }
}

private struct ContentCell: View {
    let content: ContentListViewModel.Content

    var body: some View {
        switch content {
        case let .topic(topic):
            NavigationLink(topic.title) {
                ContentListView(configuration: .init(kind: .latestMediasForTopic(topic), vendor: topic.vendor))
            }
            .swipeActions { Self.copyButton(text: topic.urn) }
        case let .media(media):
            Cell(title: media.title, subtitle: media.show?.title) {
                PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
            }
            .swipeActions { Self.copyButton(text: media.urn) }
        case let .show(show):
            NavigationLink(show.title) {
                ContentListView(configuration: .init(kind: .latestMediasForShow(show), vendor: show.vendor))
            }
            .swipeActions { Self.copyButton(text: show.urn) }
        }
    }

    @ViewBuilder
    static func copyButton(text: String) -> some View {
        Button {
            UIPasteboard.general.string = text
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .tint(.accentColor)
    }
}

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

struct ContentListView: View {
    let configuration: ContentListViewModel.Configuration
    @StateObject private var model = ContentListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
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
