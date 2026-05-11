//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let error: Error?
    let taskProperties: TaskProperties?
    let bookmarkData: Data?

    init(metadata: Metadata?, error: Error?, taskProperties: TaskProperties?, bookmarkData: Data?) {
        self.metadata = metadata
        self.error = error
        self.taskProperties = taskProperties
        self.bookmarkData = bookmarkData
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata

        var isStale = false
        if let bookmarkData = record.bookmarkData, (try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)) != nil {
            self.bookmarkData = bookmarkData
            self.error = nil
        }
        else {
            self.bookmarkData = nil
            self.error = MissingFileError()
        }
        self.taskProperties = nil
    }
}
