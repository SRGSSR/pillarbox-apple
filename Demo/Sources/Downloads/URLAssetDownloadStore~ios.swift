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
        let title: String
        let url: URL
        let isMonoscopic: Bool
        let bookmarkData: Data?
        let progress: Double
        let errorDescription: String?

        var downloadMetadata: AssetMetadata<Void> {
            .init(
                playerMetadata: .init(identifier: id, title: title, viewport: isMonoscopic ? .monoscopic : .standard),
                customData: ()
            )
        }

        private init(id: String, title: String, url: URL, isMonoscopic: Bool, bookmarkData: Data?, progress: Double, errorDescription: String?) {
            self.id = id
            self.title = title
            self.url = url
            self.isMonoscopic = isMonoscopic
            self.bookmarkData = bookmarkData
            self.progress = progress
            self.errorDescription = errorDescription
        }

        init(id: String, input: URLAssetLoader.Input) {
            self.init(
                id: id,
                title: input.title,
                url: input.url,
                isMonoscopic: input.isMonoscopic,
                bookmarkData: nil,
                progress: 0,
                errorDescription: nil
            )
        }

        init(id: String, record: DownloadRecord<URLAssetLoader.Input, Void>) {
            self.init(
                id: id,
                title: record.input.title,
                url: record.input.url,
                isMonoscopic: record.input.isMonoscopic,
                bookmarkData: record.bookmarkData,
                progress: record.progress,
                errorDescription: record.error?.localizedDescription
            )
        }

        func toDownloadRecord() -> DownloadRecord<URLAssetLoader.Input, Void> {
            .init(
                input: URLAssetLoader.Input(title: title, url: url, isMonoscopic: isMonoscopic),
                metadata: downloadMetadata,
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

extension URLAssetDownloadStore: AssetDownloadStore {
    typealias Loader = URLAssetLoader

    static func id(from input: URLAssetLoader.Input) -> String {
        input.url.absoluteString
    }

    static func customData(from metadata: Void) {}

    func downloadRecords() -> [DownloadRecord<URLAssetLoader.Input, Void>] {
        fileEntries.map { $0.toDownloadRecord() }
    }

    func addDownloadRecord(using input: URLAssetLoader.Input, forId id: String) {
        fileEntries.append(FileEntry(id: id, input: input))
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
