//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

#if DEBUG

struct DownloadError: LocalizedError {
    let errorDescription: String?

    init?(errorDescription: String?) {
        guard let errorDescription else { return nil }
        self.errorDescription = errorDescription
    }
}

class DemoAssetDownloadStore: AssetDownloadStore {
    struct FileEntry: Codable {
        let url: URL
        let title: String
        let bookmarkData: Data?
        let errorDescription: String?

        init(url: URL, title: String) {
            self.url = url
            self.title = title
            self.bookmarkData = nil
            self.errorDescription = nil
        }

        private init(url: URL, title: String, bookmarkData: Data?, errorDescription: String?) {
            self.url = url
            self.title = title
            self.bookmarkData = bookmarkData
            self.errorDescription = errorDescription
        }

        func withTitle(_ title: String) -> Self {
            .init(url: url, title: title, bookmarkData: bookmarkData, errorDescription: errorDescription)
        }

        func withBookmarkData(_ bookmarkData: Data) -> Self {
            .init(url: url, title: title, bookmarkData: bookmarkData, errorDescription: errorDescription)
        }

        func withErrorDescription(_ errorDescription: String) -> Self {
            .init(url: url, title: title, bookmarkData: bookmarkData, errorDescription: errorDescription)
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

    func downloadRecord(for identifier: String) -> DownloadRecord<DemoAssetLoader.Input, String>? {
        guard let fileEntry = fileEntries.first(where: { $0.url.absoluteString == identifier }) else {
            return nil
        }
        return DownloadRecord(
            input: DemoAssetLoader.Input(title: fileEntry.title, url: fileEntry.url),
            metadata: fileEntry.title,
            bookmarkData: fileEntry.bookmarkData,
            error: DownloadError(errorDescription: fileEntry.errorDescription)
        )
    }

    func downloadRecords() -> [DownloadRecord<DemoAssetLoader.Input, String>] {
        fileEntries.map { fileEntry in
            DownloadRecord(
                input: DemoAssetLoader.Input(title: fileEntry.title, url: fileEntry.url),
                metadata: fileEntry.title,
                bookmarkData: fileEntry.bookmarkData,
                error: DownloadError(errorDescription: fileEntry.errorDescription)
            )
        }
    }

    func addDownloadRecord(using input: DemoAssetLoader.Input, for identifier: String) -> DownloadRecord<DemoAssetLoader.Input, String> {
        let fileEntry = FileEntry(url: input.url, title: input.title)
        fileEntries.append(fileEntry)
        save()
        return DownloadRecord(
            input: DemoAssetLoader.Input(title: fileEntry.title, url: fileEntry.url),
            metadata: nil,
            bookmarkData: fileEntry.bookmarkData,
            error: DownloadError(errorDescription: fileEntry.errorDescription)
        )
    }

    func removeDownloadRecord(for identifier: String) {
        fileEntries.removeAll { $0.url.absoluteString == identifier }
        save()
    }

    func updateDownloadRecord(metadata: String, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        let fileEntry = fileEntries[index]
        fileEntries[index] = fileEntry.withTitle(metadata)
        save()
    }

    func updateDownloadRecord(bookmarkData: Data, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        let fileEntry = fileEntries[index]
        fileEntries[index] = fileEntry.withBookmarkData(bookmarkData)
        save()
    }

    func updateDownloadRecord(error: any Error, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        let fileEntry = fileEntries[index]
        fileEntries[index] = fileEntry.withErrorDescription(error.localizedDescription)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(fileEntries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
