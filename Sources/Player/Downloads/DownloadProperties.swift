//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let taskProperties: TaskProperties?
    let location: URL?
    let error: Error?

    init(metadata: Metadata?, taskProperties: TaskProperties?, location: URL?, error: Error?) {
        self.metadata = metadata
        self.taskProperties = taskProperties
        self.location = location
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        self.taskProperties = nil
        self.location = try? URL(resolvingBookmarkData: record.bookmarkData)
        self.error = record.error
    }
}
