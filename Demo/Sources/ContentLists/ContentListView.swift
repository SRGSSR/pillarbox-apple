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
    @EnvironmentObject private var router: Router

    var body: some View {
        CustomList(data: contents) { content in
            if let content {
                ContentCell(content: content)
                    .onAppear {
                        if let index = contents.firstIndex(of: content), contents.count - index < kPageSize {
                            model.loadMore()
                        }
                    }
                    .padding(.horizontal, constant(iOS: 0, tvOS: 50))
            }
        }
#if os(iOS)
        .toolbar(content: toolbar)
        .navigationTitle("Examples")
        .refreshable { await model.refresh() }
#endif
    }

    private func openPlaylist() {
        router.presented = .playlist(templates: Array(templates().prefix(20)))
    }

    private func templates() -> [Template] {
        contents.compactMap { content -> Template? in
            guard case let .media(media) = content else { return nil }
            return Template(title: media.title, description: MediaDescription.subtitle(for: media), type: .urn(media.urn))
        }
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

    @AppStorage(UserDefaults.serverSettingKey)
    private var serverSetting: ServerSetting = .production

    @EnvironmentObject private var router: Router

    var body: some View {
        switch content {
        case let .topic(topic):
#if os(iOS)
            NavigationLink(
                topic.title,
                destination: .contentList(configuration: .init(list: .latestMediasForTopic(topic), vendor: topic.vendor))
            )
            .swipeActions { CopyButton(text: topic.urn) }
#else
            NavigationLink(destination: RouterDestination.contentList(configuration: .init(list: .latestMediasForTopic(topic), vendor: topic.vendor)).view()) {
                Text(topic.title)
                    .frame(width: 300, height: 250, alignment: .leading)
            }
#endif
        case let .media(media):
            let title = MediaDescription.title(for: media)
            Cell(title: title, subtitle: MediaDescription.subtitle(for: media), style: MediaDescription.style(for: media)) {
                let media = Media(title: title, type: .urn(media.urn, server: serverSetting.server))
                router.presented = .player(media: media)
            }
#if os(iOS)
            .swipeActions { CopyButton(text: media.urn) }
#endif
        case let .show(show):
#if os(iOS)
            NavigationLink(
                show.title,
                destination: .contentList(configuration: .init(list: .latestMediasForShow(show), vendor: show.vendor))
            )
            .swipeActions { CopyButton(text: show.urn) }
#else
            NavigationLink(destination: RouterDestination.contentList(configuration: .init(list: .latestMediasForShow(show), vendor: show.vendor)).view()) {
                Text(show.title)
                    .frame(width: 300, height: 250, alignment: .leading)
            }
#endif
        }
    }
}

// Behavior: h-exp, v-exp
struct ContentListView: View {
    let configuration: ContentList.Configuration
    @StateObject private var model = ContentListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(contents: contents) where contents.isEmpty:
                RefreshableMessageView(model: model, message: "No content.", icon: .empty)
            case let .loaded(contents: contents):
                LoadedView(model: model, contents: contents)
            case let .failed(error):
                RefreshableMessageView(model: model, message: error.localizedDescription, icon: .error)
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
