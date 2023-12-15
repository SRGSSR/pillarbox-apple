//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderCombine
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
            }
        }
#if os(iOS)
        .toolbar(content: toolbar)
        .navigationTitle("Examples")
        .refreshable { await model.refresh() }
#else
        .ignoresSafeArea(.all, edges: .horizontal)
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
                CardView(title: topic.title, image: topic.image)
            }
            .buttonStyle(.card)
#endif
        case let .media(media):
            let title = MediaDescription.title(for: media)
#if os(iOS)
            Cell(title: title, subtitle: MediaDescription.subtitle(for: media), style: MediaDescription.style(for: media)) {
                let media = Media(title: title, type: .urn(media.urn, server: serverSetting.server))
                router.presented = .player(media: media)
            }
            .swipeActions { CopyButton(text: media.urn) }
#else
            Button {
                let media = Media(title: title, type: .urn(media.urn, server: serverSetting.server))
                router.presented = .player(media: media)
            } label: {
                CardView(title: title, subtitle: MediaDescription.subtitle(for: media), image: media.image, style: MediaDescription.style(for: media))
            }
            .buttonStyle(.card)
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
                CardView(title: show.title, image: show.image)
            }
            .buttonStyle(.card)
#endif
        }
    }
}

#if os(tvOS)
// Behavior: h-hug, v-exp
struct CardView: View {
    let title: String
    let subtitle: String?
    let image: SRGImage?
    let style: MediaDescription.Style?

    var body: some View {
        ZStack(alignment: .center) {
            AsyncImage(url: SRGDataProvider.current!.url(for: image, size: .large)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    EmptyView()
                }
            }
            VStack {
                Text(title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(30)
            }
            .background {
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
            }
        }
        .frame(width: 600, height: 300, alignment: .center)
    }

    init(title: String, subtitle: String? = nil, image: SRGImage? = nil, style: MediaDescription.Style? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.style = style
    }
}
#endif

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
