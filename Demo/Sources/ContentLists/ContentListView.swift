//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderCombine
import SRGDataProviderModel
import SwiftUI

private struct LoadedView: View {
    @ObservedObject var model: ContentListViewModel
    let contents: [ContentListViewModel.Content]
    @EnvironmentObject private var router: Router

    @AppStorage(UserDefaults.DemoSettingKey.serverSetting.rawValue)
    private var serverSetting: ServerSetting = .production

    var body: some View {
        CustomList(data: contents) { content in
            if let content {
                ContentCell(content: content)
                    .onAppear {
                        if let index = contents.firstIndex(of: content), contents.count - index < kPageSize {
                            model.loadMore()
                        }
                    }
            }
        }
#if os(iOS)
        .toolbar(content: toolbar)
        .refreshable { await model.refresh() }
#else
        .ignoresSafeArea(.all, edges: .horizontal)
#endif
    }

    private func medias() -> [Media] {
        contents.compactMap { content -> Media? in
            guard case let .media(media) = content else { return nil }
            return Media(
                title: media.title,
                subtitle: MediaDescription.subtitle(for: media),
                type: .urn(media.urn, serverSetting: serverSetting)
            )
        }
    }

#if os(iOS)
    private func openPlaylist() {
        router.presented = .playlist(medias: medias())
    }

    @ViewBuilder
    private func toolbar() -> some View {
        if !medias().isEmpty {
            Button(action: openPlaylist) {
                Image(systemName: "rectangle.stack.badge.play")
            }
            .accessibilityLabel("Open as playlist")
        }
    }
#endif
}

private struct ContentCell: View {
    let content: ContentListViewModel.Content

    @AppStorage(UserDefaults.DemoSettingKey.serverSetting.rawValue)
    private var serverSetting: ServerSetting = .production

    @EnvironmentObject private var router: Router

    var body: some View {
        switch content {
        case let .topic(topic):
            CustomNavigationLink(
                title: topic.title,
                destination: .contentList(configuration: .init(list: .latestMediasForTopic(topic), vendor: topic.vendor))
            ) {
#if os(tvOS)
                MediaCardView(
                    title: topic.title,
                    imageUrl: SRGDataProvider.current!.url(for: topic.image, size: .large)
                )
#endif
            }
#if os(iOS)
            .swipeActions { CopyButton(text: topic.urn) }
#endif
        case let .media(media):
            let title = MediaDescription.title(for: media)
            Cell(
                size: .init(width: 570, height: 350),
                title: constant(iOS: title, tvOS: media.show?.title),
                subtitle: constant(iOS: MediaDescription.subtitle(for: media), tvOS: media.title),
                imageUrl: SRGDataProvider.current!.url(for: media.image, size: .large),
                type: MediaDescription.systemImage(for: media),
                duration: MediaDescription.duration(for: media),
                date: MediaDescription.date(for: media),
                style: MediaDescription.style(for: media)
            ) {
                let media = Media(title: title, type: .urn(media.urn, serverSetting: serverSetting))
                router.presented = .player(media: media)
            }
#if os(iOS)
            .swipeActions { CopyButton(text: media.urn) }
#endif
        case let .show(show):
            CustomNavigationLink(
                title: show.title,
                destination: .contentList(configuration: .init(list: .latestMediasForShow(show), vendor: show.vendor))
            ) {
#if os(tvOS)
                MediaCardView(
                    title: show.title,
                    imageUrl: SRGDataProvider.current!.url(for: show.image, size: .large)
                )
#endif
            }
#if os(iOS)
            .swipeActions { CopyButton(text: show.urn) }
#endif
        }
    }
}

struct ContentListView: View {
    let configuration: ContentList.Configuration
    @StateObject private var model = ContentListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityHidden(true)
            case let .loaded(contents: contents) where contents.isEmpty:
                UnavailableModelView(model: model) {
                    Text("No items")
                }
            case let .loaded(contents: contents):
                LoadedView(model: model, contents: contents)
            case let .failed(error):
                UnavailableModelView(model: model) {
                    Label {
                        Text(error.localizedDescription)
                    } icon: {
                        Image(systemName: "exclamationmark.bubble")
                    }
                }
            }
        }
        .animation(.defaultLinear, value: model.state)
        .onAppear { model.configuration = configuration }
#if os(iOS)
        .navigationTitle(configuration.list.name)
#endif
        .tracked(name: configuration.list.pageName, levels: configuration.list.pageLevels)
    }
}

#Preview {
    NavigationStack {
        ContentListView(configuration: .init(list: .tvLatestMedias, vendor: .RTS))
    }
    .environmentObject(Router())
}
