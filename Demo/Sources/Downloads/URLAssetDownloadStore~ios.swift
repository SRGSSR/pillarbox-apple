//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

private struct DownloadError: LocalizedError {
    let errorDescription: String?

    init?(errorDescription: String?) {
        guard let errorDescription else { return nil }
        self.errorDescription = errorDescription
    }
}

final class URLAssetDownloadStore {
    private struct FileEntry: Codable {
        let id: String
        let url: URL
        let metadata: PlayerMetadata
        let bookmarkData: Data?
        let progress: Double
        let errorDescription: String?
        let creationDate: Date

        private init(
            id: String,
            url: URL,
            metadata: PlayerMetadata,
            bookmarkData: Data?,
            progress: Double,
            errorDescription: String?,
            creationDate: Date
        ) {
            self.id = id
            self.url = url
            self.metadata = metadata
            self.bookmarkData = bookmarkData
            self.progress = progress
            self.errorDescription = errorDescription
            self.creationDate = creationDate
        }

        init(id: String, record: DownloadRecord<URLAssetLoader.Input, Void>) {
            self.init(
                id: id,
                url: record.input.url,
                metadata: record.metadata?.playerMetadata ?? record.input.metadata,
                bookmarkData: record.bookmarkData,
                progress: record.progress,
                errorDescription: record.error?.localizedDescription,
                creationDate: record.creationDate
            )
        }

        func toDownloadRecord() -> DownloadRecord<URLAssetLoader.Input, Void> {
            .init(
                input: URLAssetLoader.Input(url: url, metadata: metadata),
                metadata: .init(playerMetadata: metadata, customData: ()),
                bookmarkData: bookmarkData,
                progress: progress,
                error: DownloadError(errorDescription: errorDescription),
                creationDate: creationDate
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
}

extension URLAssetDownloadStore: AssetDownloadStore {
    typealias Loader = URLAssetLoader

    static func id(from input: URLAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: Void) {}

    func downloadRecords() -> [DownloadRecord<URLAssetLoader.Input, Void>] {
        fileEntries.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
        fileEntries.append(FileEntry(id: id, record: record))
        save()
    }

    func removeDownloadRecord(forId id: String) {
        fileEntries.removeAll { $0.id == id }
        save()
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLAssetLoader.Input, Void>? {
        fileEntries.first { $0.id == id }?.toDownloadRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
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
