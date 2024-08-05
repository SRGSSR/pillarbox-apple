//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVMetadataItem {
    convenience init?<T>(identifier: AVMetadataIdentifier, value: T?) {
        guard let value else { return nil }
        let item = AVMutableMetadataItem()
        item.value = value as? NSCopying & NSObjectProtocol
        guard let value = item.value else { return nil }
        item.identifier = identifier
        item.extendedLanguageTag = "und"
        self.init(propertiesOf: item) { $0.respond(value: value) }
    }
}
