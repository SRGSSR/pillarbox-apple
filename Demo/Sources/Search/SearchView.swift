//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProvider
import SRGDataProviderModel
import SwiftUI

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    @EnvironmentObject private var router: Router

    var body: some View {
        ZStack {
            switch model.state {
            case .empty:
                UnavailableView {
                    Label {
                        Text("Enter something to search.")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            case .loading:
                ProgressView()
                    .accessibilityHidden(true)
            case let .loaded(medias: medias):
                loadedView(medias)
            case let .failed(error):
                UnavailableRefreshableView(model: model) {
                    Label {
                        Text(error.localizedDescription)
                    } icon: {
                        Image(systemName: "exclamationmark.bubble")
                    }
                }
            }
        }
        .animation(.defaultLinear, value: model.state)
        .tracked(name: "search")
        .searchable(text: $model.text)
#if os(iOS)
        .navigationTitle("Search")
        .searchScopes($model.vendor) {
            ForEach([SRGVendor.RSI, .RTR, .RTS, .SRF, .SWI], id: \.self) { vendor in
                Text(vendor.name).tag(vendor)
            }
        }
#endif
    }

    @ViewBuilder
    private func loadedView(_ medias: [SRGMedia]) -> some View {
        if !medias.isEmpty {
            CustomList(data: medias) { media in
                if let media {
                    Cell(
                        size: .init(width: 520, height: 300),
                        title: constant(iOS: MediaDescription.title(for: media), tvOS: media.show?.title),
                        subtitle: constant(iOS: MediaDescription.subtitle(for: media), tvOS: media.title),
                        imageUrl: SRGDataProvider.current!.url(for: media.image, size: .large),
                        type: MediaDescription.systemImage(for: media),
                        duration: MediaDescription.duration(for: media),
                        date: MediaDescription.date(for: media),
                        style: MediaDescription.style(for: media)
                    ) {
                        let media = Media(title: media.title, type: .urn(media.urn))
#if os(iOS)
                        router.presented = .player(media: media)
#else
                        router.presented = .systemPlayer(media: media)
#endif
                    }
                    .onAppear {
                        if let index = medias.firstIndex(of: media), medias.count - index < kPageSize {
                            model.loadMore()
                        }
                    }
#if os(iOS)
                    .swipeActions { CopyButton(text: media.urn) }
                    .refreshable { await model.refresh() }
#else
                    .ignoresSafeArea(.all, edges: .horizontal)
#endif
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        else {
            UnavailableRefreshableView(model: model) {
                Label {
                    Text("No results.")
                } icon: {
                    Image(systemName: "circle.slash")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environmentObject(Router())
}
