//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Foundation

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public struct DownloadSize {
    public let completed: Int64
    public let total: Int64

    var fractionCompleted: Double {
        Double(completed) / Double(total)
    }

    init?(completed: Int64, total: Int64) {
        guard total > 0 else { return nil }
        self.completed = completed.clamped(to: 0...total)
        self.total = total
    }

    init?(total: Int64) {
        self.init(completed: total, total: total)
    }

    init?(url: URL) {
        guard url.isFileURL else { return nil }
        if let fileSize = Self.fileSize(for: url) {
            self.init(total: Int64(fileSize))
        }
        else if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            let total = enumerator.allObjects
                .reduce(into: 0) { totalSize, object in
                    guard let url = object as? URL, let fileSize = Self.fileSize(for: url) else { return }
                    totalSize += fileSize
                }
            self.init(total: Int64(total))
        }
        else {
            return nil
        }
    }

    private static func fileSize(for url: URL) -> Int? {
        try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
    }
}

#endif

// swiftlint:enable missing_docs
