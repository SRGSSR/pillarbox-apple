//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let taskProperties: TaskProperties?
    let bookmarkData: Data?
    let error: Error?

    init(metadata: Metadata?, taskProperties: TaskProperties?, bookmarkData: Data?, error: Error?) {
        self.metadata = metadata
        self.taskProperties = taskProperties
        self.bookmarkData = bookmarkData
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        self.taskProperties = nil

        // TODO: Improve implementation
        var isStale = false
        if let bookmarkData = record.bookmarkData, (try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)) != nil {
            self.bookmarkData = bookmarkData
            self.error = nil
        }
        else {
            self.bookmarkData = nil
            self.error = MissingFileError()
        }
    }
}
