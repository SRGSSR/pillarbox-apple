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

    init<Input>(from record: DownloadRecord<Input, Metadata>?) {
        guard let record else {
            self = .init()
            return
        }

        self.metadata = record.metadata
        self.taskProperties = nil

        if let bookmarkData = record.bookmarkData {
            if let location = try? URL(resolvingBookmarkData: bookmarkData) {
                self.location = location
                self.error = record.error
            }
            else {
                self.location = nil
                self.error = MissingFileError()
            }
        }
        else {
            self.location = nil
            self.error = record.error
        }
    }

    func bookmarkData() -> Data? {
        try? location?.bookmarkData()
    }
}
