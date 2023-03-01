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

private struct ErrorView: View {
    @ObservedObject var model: MediaListViewModel
    let error: Error

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
    }
}

struct MediaListView: View {
    let kind: MediaListViewModel.Kind
    @StateObject private var model = MediaListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
            case let .loaded(medias: medias):
                LoadedView(model: model, medias: medias)
            case let .failed(error):
                ErrorView(model: model, error: error)
            }
        }
        .onAppear { model.kind = kind }
        .navigationTitle("Medias")
    }
}

struct MediaListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediaListView(kind: .tvLatestMedias(vendor: .RTS))
        }
    }
}
