//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Foundation

struct DownloadProperties<Metadata> {
    let metadata: Metadata?
    let taskProperties: TaskProperties?
    let location: URL?
    let error: Error?

    var isPreparing: Bool {
        location == nil && error == nil
    }

    var state: DownloadState {
        if let error {
            return .failed(error)
        }
        else if let taskProperties {
            switch taskProperties.state {
            case .running, .canceling:
                return .running
            case .suspended:
                return .suspended
            case .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
        else if location != nil {
            return .completed
        }
        else {
            return .preparing
        }
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

    func fileUrl(allowsPartial: Bool) -> URL? {
        switch state {
        case .completed:
            return location
        default:
            return allowsPartial ? location : nil
        }
    }
}

#endif
