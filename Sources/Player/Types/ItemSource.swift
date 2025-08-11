//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ItemSource {
    private let content: AssetContent
    private let item: AVPlayerItem?

    static func new(content: AssetContent) -> Self {
        .init(content: content, item: nil)
    }

    static func reused(content: AssetContent, item: AVPlayerItem) -> Self {
        .init(content: content, item: item)
    }

    func copy() -> Self {
        .init(content: content, item: nil)
    }

    func playerItem(reload: Bool, configuration: PlayerConfiguration, resumeState: ResumeState?) -> AVPlayerItem {
        if let item {
            return item.updated(with: content)
        }
        else {
            return content.playerItem(reload: reload, configuration: configuration, resumeState: resumeState)
        }
    }
}
