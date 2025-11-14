//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVQueuePlayer {
    func replaceItems(with items: [AVPlayerItem]) {
        guard self.items() != items else { return }

        if let firstItem = items.first {
            let currentItem = self.items().first
            if firstItem !== currentItem {
                safelyReplaceCurrentItem(with: firstItem)
            }
            removeAll(from: 1)
            if items.count > 1 {
                append(Array(items.suffix(from: 1)))
            }
        }
        else {
            removeAllItems()
        }
    }

    private func removeAll(from index: Int) {
        assert(index > 0, "The current item must not be removed")
        guard items().count > index else { return }
        items().suffix(from: index).forEach { remove($0) }
    }

    private func append(_ items: [AVPlayerItem]) {
        items.forEach { insert($0, after: nil) }
    }

    private func safelyReplaceCurrentItem(with item: AVPlayerItem) {
        // TODO: Workaround to fix incorrect recovery from failed MP3 playback (FB13650115). Remove when fixed.
        if let currentItem = items().first, currentItem.error != nil {
            removeAllItems()
        }
        // End of workaround
        else {
            remove(item)
        }
        if #available(tvOS 26, *) {
            if let firstItem = items().first, firstItem.isLoading {
                DispatchQueue.main.async {
                    firstItem.asset.cancelLoading()
                }
            }
        }
        replaceCurrentItem(with: item)
    }
}
