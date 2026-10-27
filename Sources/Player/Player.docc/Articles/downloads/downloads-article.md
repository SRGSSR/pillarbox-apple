# Downloads

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: downloads-card, alt: "An image depicting a download arrow in a circle.")
}

Download content to play it offline.

## Overview

A ``Downloader`` is an [observable object](https://developer.apple.com/documentation/combine/observableobject) that manages a persistent list of downloads. Each ``Download`` is itself observable, so your user interface can reflect its progress and state as it changes.

A downloader loads content with an ``AssetLoader`` and persists downloads with an ``AssetDownloadStore`` that you provide.

> Important: Downloads aren't supported on tvOS.

### Implement a download store

Suppose you have a `MediaAssetLoader` that loads a `Media` from a `String` identifier, as described in <doc:playback-article> and <doc:metadata-article>. The loader already describes how to fetch metadata, build the ``Asset`` to download and derive ``PlayerMetadata``. A download store adds what's needed to persist downloads and play them offline:

```swift
final class MediaDownloadStore: AssetDownloadStore {
    typealias Loader = MediaAssetLoader

    private var records: [String: DownloadRecord<String, Void>] = [:]

    static func id(from input: String) -> String {
        input
    }

    static func customData(from metadata: Media) {}

    static func asset(fileUrl: URL, customData: Void) -> Asset {
        .simple(url: fileUrl)
    }

    func downloadRecords() -> [DownloadRecord<String, Void>] {
        Array(records.values)
    }

    func addDownloadRecord(_ record: DownloadRecord<String, Void>, forId id: String) {
        records[id] = record
    }

    func removeDownloadRecord(forId id: String) {
        records.removeValue(forKey: id)
    }

    func downloadRecord(forId id: String) -> DownloadRecord<String, Void>? {
        records[id]
    }

    func updateDownloadRecord(_ record: DownloadRecord<String, Void>, forId id: String) {
        records[id] = record
    }
}
```

The store:

- Declares which ``AssetLoader`` it works with.
- Identifies each download uniquely from its input with ``AssetDownloadStore/id(from:)``.
- Persists each ``DownloadRecord`` with the record methods. This example keeps records in memory for brevity, but a real store must save them to disk, for example with [SwiftData](https://developer.apple.com/documentation/swiftdata), so that downloads are restored when your app is launched again.
- Builds the ``Asset`` that plays a downloaded file with ``AssetDownloadStore/asset(fileUrl:customData:)``.
- Extracts the ``AssetDownloadStore/CustomData`` to persist with each download from the loader metadata with ``AssetDownloadStore/customData(from:)``. Custom data is delivered to trackers when playing the download, and should contain everything needed to rebuild the local asset, for example to play encrypted content. Use `Void` if you don't need any.

> Tip: Implement ``AssetLoader/downloadableAssetPublisher(from:metadata:)`` if the asset to download differs from the asset to stream, and ``AssetDownloadStore/playerMetadata(from:metadata:)`` if downloads should display different metadata.

### Set up a downloader

Create a single ``Downloader`` for your app with your store, and share it with your views, for example through the environment:

```swift
@main
struct MyApp: App {
    @StateObject private var downloader = Downloader(
        configuration: .background(withIdentifier: "com.example.downloads"),
        store: MediaDownloadStore()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(downloader)
        }
    }
}
```

When the downloader is created, it restores the downloads saved in the store.

> Warning: Downloaders require a background session configuration, created with [`background(withIdentifier:)`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/background(withidentifier:)). Background configurations support reliable downloading while your app is suspended. Use a different identifier for each downloader.

### Display the list of downloads

Observe ``Downloader/downloads`` to list downloads. Since ``Download`` is identifiable, you can pass the list directly to a [List](https://developer.apple.com/documentation/swiftui/list):

```swift
struct DownloadsView: View {
    @EnvironmentObject private var downloader: Downloader<MediaDownloadStore>

    var body: some View {
        List(downloader.downloads) { download in
            DownloadCell(download: download)
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        downloader.removeDownload(download)
                    }
                }
        }
    }
}
```

Remove downloads with ``Downloader/removeDownload(_:)`` or ``Downloader/removeAllDownloads()``. Associated files are deleted automatically.

> Note: Users can also remove downloaded files from the Storage section of the Settings app. These changes are only reflected in your app the next time it's launched.

### Display the status of a download

Observe each ``Download`` from its cell so that only this cell is updated when the download progresses:

```swift
struct DownloadCell: View {
    @ObservedObject var download: Download

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(download.metadata.title ?? "Untitled")
                if let size = download.size {
                    Text(size.localizedDescription)
                        .font(.caption)
                }
            }
            Spacer()
            statusView()
        }
    }

    @ViewBuilder
    private func statusView() -> some View {
        if download.error != nil {
            Button(action: download.restart) {
                Image(systemName: "arrow.counterclockwise")
            }
        }
        else {
            switch download.state {
            case .preparing:
                ProgressView()
            case .running:
                Button(action: download.suspend) {
                    ProgressView(value: download.progress)
                }
            case .suspended:
                Button(action: download.resume) {
                    Image(systemName: "play.fill")
                }
            case .completed:
                Image(systemName: "checkmark")
            }
        }
    }
}
```

A download exposes:

- Its ``Download/state``, its ``Download/progress`` (between 0 and 1), its ``Download/size`` and its ``Download/error``, if any.
- The ``Download/metadata`` of the content, as returned by your asset loader. It includes an image source, which you can display with ``LazyImage``.

Control a download with ``Download/suspend()``, ``Download/resume()`` and ``Download/restart()``. Use ``Download/restart(configuration:)`` to restart with a different ``DownloadConfiguration``.

### Add a download button

Call ``Downloader/addDownload(for:configuration:)`` with an input to start downloading the associated content. The downloader fetches metadata with your asset loader and persists it, so that the download can be displayed and played without a network connection:

```swift
struct DownloadButton: View {
    let identifier: String

    @EnvironmentObject private var downloader: Downloader<MediaDownloadStore>

    var body: some View {
        Button {
            downloader.addDownload(for: identifier)
        } label: {
            Image(systemName: "arrow.down.circle")
        }
    }
}
```

If a download already exists for the input, the existing download is returned instead of a new one. Use ``Downloader/download(matching:)`` to retrieve it, for example to display its status with the cell view above rather than a download button.

> Tip: Pass a ``DownloadConfiguration`` to limit the downloaded quality with ``DownloadConfiguration/preferredPeakBitRate`` or ``DownloadConfiguration/preferredMaximumResolution``, or to select which audio and subtitle languages are downloaded with ``DownloadConfiguration/setMediaSelectionPreference(_:for:)``.

### Play downloaded content

Call ``Downloader/playerItem(for:trackerAdapters:)`` to create a ``PlayerItem`` that plays a downloaded file. The method returns `nil` while the download isn't playable yet:

```swift
if let item = downloader.playerItem(for: download) {
    player.items = [item]
    player.play()
}
```

The item is built with your store's ``AssetDownloadStore/asset(fileUrl:customData:)`` and the metadata persisted with the download, so no network connection is required. Like any other item, it can be inserted into a playlist, for example to play all available downloads in a row:

```swift
let player = Player(items: downloader.downloads.compactMap { downloader.playerItem(for: $0) })
```

To track playback of downloaded content, pass ``TrackerAdapter`` instances when creating the item. They receive the persisted metadata, including the custom data your store extracts with ``AssetDownloadStore/customData(from:)``. For more information, see <doc:tracking-article>.

### Download URL-based content

If you play content from URLs without a custom ``AssetLoader``, use ``URLDownloader`` instead of implementing a store yourself. A URL downloader persists its downloads with SwiftData and is available on iOS 17 and above.

> Important: URL downloaders persist downloads with [SwiftData](https://developer.apple.com/documentation/swiftdata), which is only available on iOS 17 and above. If your app supports iOS 16, add `SwiftData.framework` to the _Frameworks, Libraries, and Embedded Content_ section of your app target and set its status to _Optional_. Otherwise, your app crashes at launch on iOS 16.

Create a URL downloader and add downloads with their metadata:

```swift
let downloader = try URLDownloader(configuration: .background(withIdentifier: "com.example.url-downloads"))
downloader.addDownload(url: url, metadata: .init(title: "My video"))
```

> Warning: URL downloaders also require a background session configuration, created with [`background(withIdentifier:)`](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/background(withidentifier:)). Background configurations support reliable downloading while your app is suspended. Use a different identifier for each downloader.

Since the content has no asset loader, provide its metadata when adding the download with ``URLDownloader/addDownload(url:metadata:configuration:)-(_,AssetMetadata<Provider.CustomData>,_)``. The rest of the API matches the one of ``Downloader``, with ``URLDownloader/downloads``, ``URLDownloader/playerItem(for:trackerAdapters:)`` and the removal methods.

To build custom assets or to persist custom data with each download, for example for tracking purposes, implement a ``URLAssetDownloadStoreProvider``:

```swift
enum MediaAssetProvider: URLAssetDownloadStoreProvider {
    struct CustomData: Codable {
        let analyticsId: String
    }

    static func asset(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> Asset {
        .simple(url: input.url)
    }

    static func asset(fileUrl: URL, customData: CustomData) -> Asset {
        .simple(url: fileUrl)
    }
}
```

The provider builds the asset to stream with ``URLAssetLoaderProvider/asset(from:metadata:)`` and the asset that plays a downloaded file with ``URLAssetDownloadStoreProvider/asset(fileUrl:customData:)``. Create the downloader with ``URLDownloader/init(name:storeProviderType:configuration:)`` and provide custom data in the metadata of each download:

```swift
let downloader = try URLDownloader(
    storeProviderType: MediaAssetProvider.self,
    configuration: .background(withIdentifier: "com.example.url-downloads")
)
downloader.addDownload(url: url, metadata: .init(title: "My video", customData: .init(analyticsId: "1234")))
```

The same provider can stream content with ``PlayerItem/custom(assetProviderType:url:metadata:trackerAdapters:)``. ``URLEmptyAssetProvider`` is the provider used when no custom data is needed.

> Tip: If your app uses several URL downloaders, give each one a different `name`.
