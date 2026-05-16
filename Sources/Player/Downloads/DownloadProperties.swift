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

    var isPreparing: Bool {
        location == nil && error == nil
    }

    init() {
        self.init(metadata: nil, taskProperties: nil, location: nil, error: nil)
    }

    init(metadata: Metadata?, taskProperties: TaskProperties?, location: URL?, error: Error?) {
        self.metadata = metadata
        self.taskProperties = taskProperties
        self.location = location
        self.error = error
    }

    init<Input>(from record: DownloadRecord<Input, Metadata>) {
        self.metadata = record.metadata
        self.taskProperties = nil
        do {
            self.location = try URL(resolvingBookmarkData: record.bookmarkData)
            self.error = nil
        }
        catch {
            self.location = nil
            self.error = error
        }
    }

    func bookmarkData() -> Data? {
        try? location?.bookmarkData()
    }
}
