//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

private struct LoadedView: View {
    @ObservedObject var model: MediaListViewModel
    let contents: [MediaListViewModel.Content]

    var body: some View {
        List(contents, id: \.self) { content in
            ContentCell(content: content)
                .onAppear {
                    if contents.last == content {
                        model.loadMore()
                    }
                }
        }
        .refreshable { await model.refresh() }
    }
}

private struct ContentCell: View {
    let content: MediaListViewModel.Content

    var body: some View {
        switch content {
        case let .topic(topic):
            NavigationLink(topic.title) {
                MediaListView(configuration: .init(kind: .latestMediasForTopic(topic), vendor: topic.vendor))
            }
        case let .media(media):
            Cell(title: media.title, subtitle: media.show?.title) {
                PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
            }
        }
    }
}

private struct MessageView: View {
    @ObservedObject var model: MediaListViewModel
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

struct MediaListView: View {
    let configuration: MediaListViewModel.Configuration
    @StateObject private var model = MediaListViewModel()

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
        .navigationTitle("Medias")
    }
}

struct MediaListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediaListView(configuration: .init(kind: .tvLatestMedias, vendor: .RTS))
        }
    }
}
