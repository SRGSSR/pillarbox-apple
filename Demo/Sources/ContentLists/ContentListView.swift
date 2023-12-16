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
            CustomNavigationLink(
                title: topic.title,
                destination: .contentList(configuration: .init(list: .latestMediasForTopic(topic), vendor: topic.vendor))
            ) {
                CardView(title: topic.title, image: topic.image)
            }
#if os(iOS)
            .swipeActions { CopyButton(text: topic.urn) }
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
                CardView(
                    title: media.show?.title,
                    subtitle: media.title,
                    image: media.image,
                    type: MediaDescription.systemImage(for: media),
                    duration: MediaDescription.duration(for: media),
                    date: MediaDescription.date(for: media)
                )
            }
            .buttonStyle(.card)
#endif
        case let .show(show):
            CustomNavigationLink(
                title: show.title,
                destination: .contentList(configuration: .init(list: .latestMediasForShow(show), vendor: show.vendor))
            ) {
                CardView(title: show.title, image: show.image)
            }
#if os(iOS)
            .swipeActions { CopyButton(text: show.urn) }
#endif
        }
    }
}

#if os(tvOS)
// Behavior: h-hug, v-hug
private struct CardView: View {
    static let width: CGFloat = 570
    static let height: CGFloat = 350

    let title: String?
    let subtitle: String?
    let image: SRGImage?
    let type: String?
    let duration: String?
    let date: String?

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
            .overlay {
                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .top, endPoint: .bottom)
            }
            .frame(width: Self.width, height: Self.height, alignment: .center)

            VStack {
                CardTopTrailingView(duration: duration, type: type)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Spacer()
                CardBottomView(title: title, description: subtitle, date: date)
            }
        }
        .frame(width: Self.width, height: Self.height, alignment: .center)
    }

    init(
        title: String?,
        subtitle: String? = nil,
        image: SRGImage? = nil,
        type: String? = nil,
        duration: String? = nil,
        date: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.type = type
        self.duration = duration
        self.date = date
    }
}

// Behavior: h-hug, v-hug
private struct CardTopTrailingView: View {
    let duration: String?
    let type: String?

    var body: some View {
        if let type {
            VStack {
                Image(systemName: type)
                if let duration {
                    Text(duration)
                        .font(.caption2)
                        .scaleEffect(0.7)
                }
            }
            .tint(.white)
            .shadow(color: .black, radius: 5)
            .padding()
        }
    }
}

// Behavior: h-hug, v-hug
private struct CardBottomView: View {
    let title: String?
    let description: String?
    let date: String?

    var body: some View {
        VStack(spacing: 5) {
            if let title {
                Text(title)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.bottom, description == nil ? 30 : 0)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            if let description {
                Text(description)
                    .foregroundStyle(Color(uiColor: UIColor.lightGray))
                    .font(.caption2)
                    .padding(.horizontal, 50)
                    .padding(.bottom, date == nil ? 30 : 0)
                    .lineLimit(2)
            }
            if let date {
                Text(date)
                    .foregroundStyle(Color(uiColor: UIColor.lightGray))
                    .font(.caption2)
                    .scaleEffect(0.7)
                    .padding(.bottom, 10)
            }
        }
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
