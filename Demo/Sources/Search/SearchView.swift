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

    @AppStorage(UserDefaults.DemoSettingKey.serverSetting.rawValue)
    private var serverSetting: ServerSetting = .production

    var body: some View {
        ZStack {
            switch model.state {
            case .empty:
                emptyView()
            case .loading:
                ProgressView()
                    .accessibilityHidden(true)
            case let .loaded(medias: medias) where medias.isEmpty:
                unavailableModelView(title: "No results.", icon: "circle.slash")
            case let .loaded(medias: medias):
                loadedView(medias)
            case let .failed(error):
                unavailableModelView(title: error.localizedDescription, icon: "exclamationmark.bubble")
            }
        }
        .animation(.defaultLinear, value: model.animationValue)
        .tracked(name: "search")
        .searchable(text: $model.text)
#if os(iOS)
        .navigationTitle("Search")
#endif
        .searchScopes16_4($model.vendor) {
            ForEach([SRGVendor.RSI, .RTR, .RTS, .SRF], id: \.self) { vendor in
                Text(vendor.name).tag(vendor)
            }
        }
    }

    @ViewBuilder
    private func loadedView(_ medias: [SRGMedia]) -> some View {
        // swiftlint:disable:next closure_body_length
        CustomList(data: medias) { srgMedia in
            if let srgMedia {
                let media = Media(title: srgMedia.title, type: .urn(srgMedia.urn))
                Cell(
                    size: .init(width: 520, height: 300),
                    title: constant(iOS: MediaDescription.title(for: srgMedia), tvOS: srgMedia.show?.title),
                    subtitle: constant(iOS: MediaDescription.subtitle(for: srgMedia), tvOS: srgMedia.title),
                    imageUrl: SRGDataProvider.current!.url(for: srgMedia.image, size: .large),
                    type: MediaDescription.systemImage(for: srgMedia),
                    duration: MediaDescription.duration(for: srgMedia),
                    date: MediaDescription.date(for: srgMedia),
                    style: MediaDescription.style(for: srgMedia)
                ) {
                    router.presented = .player(media: media)
                }
                .onAppear {
                    if let index = medias.firstIndex(of: srgMedia), medias.count - index < kPageSize {
                        model.loadMore()
                    }
                }
#if os(iOS)
                .swipeActions {
                    CopyActions(text: srgMedia.urn)
#if DEBUG
                    DownloadAction(media: media)
#endif
                }
                .refreshable { await model.refresh() }
#else
                .ignoresSafeArea(.all, edges: .horizontal)
#endif
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func emptyView() -> some View {
        UnavailableView {
            Label {
                Text("Enter something to search.")
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        }
    }

    private func unavailableModelView(title: String, icon: String) -> some View {
        UnavailableModelView(model: model) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: icon)
            }
        }
    }

    private func unavailableModelView(title: LocalizedStringResource, icon: String) -> some View {
        unavailableModelView(title: String(localized: title), icon: icon)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environmentObject(Router())
}
