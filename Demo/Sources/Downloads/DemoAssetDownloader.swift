//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

#if DEBUG

class DemoAssetDownloader: AssetDownloader {
    typealias Loader = DemoAssetLoader

    struct FileEntry: Codable {
        let url: URL
        let title: String
        let bookmarkData: Data?

        func withTitle(_ title: String) -> Self {
            .init(url: url, title: title, bookmarkData: bookmarkData)
        }

        func withBookmarkData(_ bookmarkData: Data) -> Self {
            .init(url: url, title: title, bookmarkData: bookmarkData)
        }
    }

    private let metadataFileUrl: URL
    private var fileEntries: [FileEntry]

    init(fileName: String) {
        metadataFileUrl = URL.libraryDirectory.appending(component: fileName)
        if let jsonData = try? Data(contentsOf: metadataFileUrl),
           let fileEntries = try? JSONDecoder().decode([FileEntry].self, from: jsonData) {
            self.fileEntries = fileEntries
        }
        else {
            self.fileEntries = []
        }
    }

    func identifier(for input: DemoAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    func download(for identifier: String) -> DownloadData<DemoAssetLoader.Input, String>? {
        guard let fileData = fileEntries.first(where: { $0.url.absoluteString == identifier }) else {
            return nil
        }
        return DownloadData(
            input: DemoAssetLoader.Input(title: fileData.title, url: fileData.url),
            metadata: fileData.title,
            bookmarkData: fileData.bookmarkData
        )
    }

    func downloads() -> [DownloadData<DemoAssetLoader.Input, String>] {
        fileEntries.map { fileData in
            DownloadData(
                input: DemoAssetLoader.Input(title: fileData.title, url: fileData.url),
                metadata: fileData.title,
                bookmarkData: fileData.bookmarkData
            )
        }
    }

    func addDownload(using input: DemoAssetLoader.Input, for identifier: String) -> DownloadData<DemoAssetLoader.Input, String> {
        let fileEntry = FileEntry(url: input.url, title: input.title, bookmarkData: nil)
        fileEntries.append(fileEntry)
        save()
        return DownloadData(
            input: DemoAssetLoader.Input(title: fileEntry.title, url: fileEntry.url),
            metadata: nil,
            bookmarkData: fileEntry.bookmarkData
        )
    }

    func removeDownload(for identifier: String) {
        fileEntries.removeAll { $0.url.absoluteString == identifier }
        save()
    }

    func updateDownload(metadata: String, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        let fileEntry = fileEntries[index]
        fileEntries[index] = fileEntry.withTitle(metadata)
        save()
    }

    func updateDownload(bookmarkData: Data, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        let fileEntry = fileEntries[index]
        fileEntries[index] = fileEntry.withBookmarkData(bookmarkData)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(fileEntries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
