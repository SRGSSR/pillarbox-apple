//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension URL {
    // Provide a playlist extension so that resource loader errors are correctly forwarded through the resource loader.
    static let loading = URL(string: "pillarbox://loading.m3u8")!
    static let failing = URL(string: "pillarbox://failing.m3u8")!
}
