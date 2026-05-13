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

final class DemoAssetDownloadStore: AssetDownloadStore {
    struct FileEntry: Codable {
        let url: URL
        let metadata: String?
        let bookmarkData: Data?
        let errorDescription: String?

        init(input: DemoAssetLoader.Input) {
            self.url = input.url
            self.metadata = nil
            self.bookmarkData = nil
            self.errorDescription = nil
        }

        init(from record: DownloadRecord<DemoAssetLoader.Input, String>) {
            self.url = record.input.url
            self.metadata = record.metadata
            self.bookmarkData = record.bookmarkData
            self.errorDescription = record.error?.localizedDescription
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

    static func identifier(for input: DemoAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    func downloadRecord(for identifier: String) -> DownloadRecord<DemoAssetLoader.Input, String>? {
        guard let fileEntry = fileEntries.first(where: { $0.url.absoluteString == identifier }) else {
            return nil
        }
        return DownloadRecord(
            input: DemoAssetLoader.Input(url: fileEntry.url),
            metadata: fileEntry.metadata,
            bookmarkData: fileEntry.bookmarkData,
            error: DownloadError(errorDescription: fileEntry.errorDescription)
        )
    }

    func downloadRecords() -> [DownloadRecord<DemoAssetLoader.Input, String>] {
        fileEntries.map { fileEntry in
            DownloadRecord(
                input: DemoAssetLoader.Input(url: fileEntry.url),
                metadata: fileEntry.metadata,
                bookmarkData: fileEntry.bookmarkData,
                error: DownloadError(errorDescription: fileEntry.errorDescription)
            )
        }
    }

    func addDownloadRecord(using input: DemoAssetLoader.Input, for identifier: String) {
        let fileEntry = FileEntry(input: input)
        fileEntries.append(fileEntry)
        save()
    }

    func removeDownloadRecord(for identifier: String) {
        fileEntries.removeAll { $0.url.absoluteString == identifier }
        save()
    }

    func updateDownloadRecord(_ record: DownloadRecord<DemoAssetLoader.Input, String>, for identifier: String) {
        guard let index = fileEntries.firstIndex(where: { $0.url.absoluteString == identifier }) else { return }
        fileEntries[index] = .init(from: record)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(fileEntries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
