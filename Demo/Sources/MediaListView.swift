//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

private struct LoadedView: View {
    @ObservedObject var model: MediaListViewModel
    let medias: [SRGMedia]

    var body: some View {
        List(medias, id: \.urn) { media in
            Cell(title: media.title, subtitle: media.show?.title) {
                PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
            }
            .onAppear {
                if medias.last == media {
                    model.loadMore()
                }
            }
        }
        .refreshable { await model.refresh() }
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
            case let .loaded(medias: medias) where medias.isEmpty:
                MessageView(model: model, message: "No content.")
            case let .loaded(medias: medias):
                LoadedView(model: model, medias: medias)
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
