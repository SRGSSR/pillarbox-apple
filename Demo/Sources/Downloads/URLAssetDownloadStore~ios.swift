//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

final class URLAssetDownloadStore {
    private struct EntryError: Codable {
        private let domain: String
        private let code: Int
        private let description: String

        init?(error: Error?) {
            guard let error else { return nil }
            let nsError = error as NSError
            self.domain = nsError.domain
            self.code = nsError.code
            self.description = nsError.localizedDescription
        }

        func error() -> Error {
            NSError(domain: domain, code: code, userInfo: [
                NSLocalizedDescriptionKey: description
            ])
        }
    }

    private struct Entry: Codable {
        let id: String
        let url: URL
        let metadata: PlayerMetadata
        let bookmarkData: Data?
        let progress: Double
        let error: EntryError?
        let creationDate: Date

        private init(
            id: String,
            url: URL,
            metadata: PlayerMetadata,
            bookmarkData: Data?,
            progress: Double,
            error: EntryError?,
            creationDate: Date
        ) {
            self.id = id
            self.url = url
            self.metadata = metadata
            self.bookmarkData = bookmarkData
            self.progress = progress
            self.error = error
            self.creationDate = creationDate
        }

        init(id: String, record: DownloadRecord<URLAssetLoader.Input, Void>) {
            self.init(
                id: id,
                url: record.input.url,
                metadata: record.metadata?.playerMetadata ?? record.input.metadata,
                bookmarkData: record.bookmarkData,
                progress: record.progress,
                error: .init(error: record.error),
                creationDate: record.creationDate
            )
        }

        func toDownloadRecord() -> DownloadRecord<URLAssetLoader.Input, Void> {
            .init(
                input: URLAssetLoader.Input(url: url, metadata: metadata),
                metadata: .init(playerMetadata: metadata, customData: ()),
                bookmarkData: bookmarkData,
                progress: progress,
                error: error?.error(),
                creationDate: creationDate
            )
        }
    }

    private let metadataFileUrl: URL
    private var entries: [Entry]

    init(fileName: String) {
        metadataFileUrl = URL.libraryDirectory.appending(component: fileName)
        if let jsonData = try? Data(contentsOf: metadataFileUrl),
           let entries = try? JSONDecoder().decode([Entry].self, from: jsonData) {
            self.entries = entries
        }
        else {
            self.entries = []
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
        entries.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
        entries.append(Entry(id: id, record: record))
        save()
    }

    func removeDownloadRecord(forId id: String) {
        entries.removeAll { $0.id == id }
        save()
    }

    func downloadRecord(forId id: String) -> DownloadRecord<URLAssetLoader.Input, Void>? {
        entries.first { $0.id == id }?.toDownloadRecord()
    }

    func updateDownloadRecord(_ record: DownloadRecord<URLAssetLoader.Input, Void>, forId id: String) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index] = .init(id: id, record: record)
        save()
    }

    private func save() {
        guard let jsonData = try? JSONEncoder().encode(entries) else { return }
        try? jsonData.write(to: metadataFileUrl)
    }
}

#endif
