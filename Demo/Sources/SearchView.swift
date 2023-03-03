//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

private struct MessageView: View {
    @ObservedObject var model: SearchViewModel
    let message: String
    let icon: String

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 90, height: 90)
                    Text(message)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .foregroundColor(.secondary)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .refreshable { await model.refresh() }
        }
    }
}

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
            case let .loaded(medias: medias):
                loadedView(medias)
            case let .failed(error):
                MessageView(model: model, message: error.localizedDescription, icon: "exclamationmark.bubble")
            }
        }
        .navigationTitle("Search")
        .searchable(text: $model.text)
        .searchScopes($model.vendor) {
            Text(SRGVendor.RTS.name).tag(SRGVendor.RTS)
            Text(SRGVendor.SRF.name).tag(SRGVendor.SRF)
            Text(SRGVendor.RSI.name).tag(SRGVendor.RSI)
            Text(SRGVendor.RTR.name).tag(SRGVendor.RTR)
            Text(SRGVendor.SWI.name).tag(SRGVendor.SWI)
        }
    }

    @ViewBuilder
    func loadedView(_ medias: [SRGMedia]) -> some View {
        if !medias.isEmpty {
            List(medias, id: \.urn) { media in
                Cell(title: media.title, subtitle: media.show?.title) {
                    PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
                }
                .onAppear {
                    if let index = medias.firstIndex(of: media), medias.count - index < kPageSize {
                        model.loadMore()
                    }
                }
#if os(iOS)
                .swipeActions { CopyButton(text: media.urn) }
#endif
            }
            .refreshable { await model.refresh() }
        }
        else if model.text.isEmpty {
            Text("Enter something to search.")
        }
        else {
            MessageView(model: model, message: "No results.", icon: "circle.slash")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}
