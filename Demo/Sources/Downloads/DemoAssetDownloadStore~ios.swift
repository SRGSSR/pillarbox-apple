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

final class DemoAssetDownloadStore {
    private struct FileEntry: Codable {
        let id: String
        let title: String
        let url: URL
        let metadata: String?
        let bookmarkData: Data?
        let progress: Double
        let errorDescription: String?

        init(id: String, input: DemoAssetLoader.Input) {
            self.id = id
            self.title = input.title
            self.url = input.url
            self.metadata = nil
            self.bookmarkData = nil
            self.progress = 0
            self.errorDescription = nil
        }

        init(id: String, record: DownloadRecord<DemoAssetLoader.Input, String>) {
            self.id = id
            self.title = record.input.title
            self.url = record.input.url
            self.metadata = record.metadata
            self.bookmarkData = record.bookmarkData
            self.progress = record.progress
            self.errorDescription = record.error?.localizedDescription
        }

        func toDownloadRecord() -> DownloadRecord<DemoAssetLoader.Input, String> {
            .init(
                input: DemoAssetLoader.Input(title: title, url: url),
                metadata: metadata,
                bookmarkData: bookmarkData,
                progress: progress,
                error: DownloadError(errorDescription: errorDescription)
            )
        }
    }

    private let metadataFileUrl: URL
    private var fileEntries: [FileEntry]

    init(fileName: String) {
        metadataFileUrl = URL.libraryDirectory.appending(component: fileName)
        if let jsonData = try? Data(contentsOf: metadataFileUrl), let fileEntries = try? JSONDecoder().decode([FileEntry].self, from: jsonData) {
            self.fileEntries = fileEntries
        }
        else {
            self.fileEntries = []
        }
    }
}

extension DemoAssetDownloadStore: AssetDownloadStore {
    static func id(from input: DemoAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    static func playerMetadata(from input: Input, metadata: String?) -> PlayerMetadata {
        .init(title: metadata ?? input.title)
    }

    func downloadRecords() -> [DownloadRecord<DemoAssetLoader.Input, String>] {
        fileEntries.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(using input: DemoAssetLoader.Input, forId id: String) {
        fileEntries.append(FileEntry(id: id, input: input))
        save()
    }

    func removeDownloadRecord(forId id: String) {
        fileEntries.removeAll { $0.id == id }
        save()
    }

    func downloadRecord(forId id: String) -> DownloadRecord<DemoAssetLoader.Input, String>? {
        fileEntries.first { $0.id == id }?.toDownloadRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<DemoAssetLoader.Input, String>, forId id: String) {
        guard let index = fileEntries.firstIndex(where: { $0.id == id }) else { return }
        fileEntries[index] = .init(id: id, record: record)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(fileEntries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
