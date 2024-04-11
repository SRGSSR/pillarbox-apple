//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct Null {}

extension Null: PlayerItemMetadata {
    public func items() -> [AVMetadataItem] { [] }
    public func timedGroups() -> [AVTimedMetadataGroup] { [] }
    public func chapterGroups() -> [AVTimedMetadataGroup] { [] }
}
