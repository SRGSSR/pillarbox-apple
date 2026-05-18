//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

#if DEBUG

private struct DownloadError: LocalizedError {
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

        var id: String {
            url.absoluteString
        }

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

        func toDownloadRecord() -> DownloadRecord<DemoAssetLoader.Input, String> {
            .init(
                id: id,
                input: DemoAssetLoader.Input(url: url),
                metadata: metadata,
                bookmarkData: bookmarkData,
                error: DownloadError(errorDescription: errorDescription)
            )
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

    static func asset(fileUrl: URL, input: DemoAssetLoader.Input, metadata: String) -> Asset<String> {
        .simple(url: fileUrl, metadata: metadata)
    }

    static func playerMetadata(from metadata: String) -> PlayerMetadata {
        .init(title: metadata)
    }

    func downloadRecords() -> [DownloadRecord<DemoAssetLoader.Input, String>] {
        fileEntries.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(using input: DemoAssetLoader.Input) -> DownloadRecord<DemoAssetLoader.Input, String> {
        let fileEntry = FileEntry(input: input)
        fileEntries.append(fileEntry)
        save()
        return fileEntry.toDownloadRecord()
    }

    func removeDownloadRecord(forId id: String) {
        fileEntries.removeAll { $0.id == id }
        save()
    }

    func downloadRecord(forId id: String) -> DownloadRecord<DemoAssetLoader.Input, String>? {
        fileEntries.first { $0.id == id }?.toDownloadRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<DemoAssetLoader.Input, String>) {
        guard let index = fileEntries.firstIndex(where: { $0.id == record.id }) else { return }
        fileEntries[index] = .init(from: record)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(fileEntries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
