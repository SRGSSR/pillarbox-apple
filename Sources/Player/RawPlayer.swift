//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class RawPlayer: AVQueuePlayer {
    @Published private(set) var chunkDuration: CMTime = .invalid

    private var seekCount = 0

    override init() {
        super.init()
        configureChunkDurationPublisher()
    }

    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        configureChunkDurationPublisher()
    }

    override init(items: [AVPlayerItem]) {
        super.init(items: items)
        configureChunkDurationPublisher()
    }

    private static func safeSeekTime(_ time: CMTime, for item: AVPlayerItem?, chunkDuration: CMTime) -> CMTime {
        guard chunkDuration.isValid, let item, let timeRange = item.timeRange, !item.duration.isIndefinite else {
            return time
        }
        return CMTimeMinimum(time, CMTimeMaximum(timeRange.end - chunkDuration, .zero))
    }

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        if seekCount == 0 {
            NotificationCenter.default.post(name: .willSeek, object: self)
        }
        seekCount += 1
        super.seek(
            to: Self.safeSeekTime(time, for: currentItem, chunkDuration: chunkDuration),
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter
        ) { [weak self] finished in
            guard let self else { return }
            self.seekCount -= 1
            if self.seekCount == 0 {
                NotificationCenter.default.post(name: .didSeek, object: self)
            }
            completionHandler(finished)
        }
    }

    func replaceItems(with items: [AVPlayerItem]) {
        cancelPendingReplacements()

        guard self.items() != items else { return }

        if let firstItem = items.first {
            if firstItem !== self.items().first {
                removeAllItems()
                replaceCurrentItem(with: firstItem)
            }
            else if self.items().count > 1 {
                self.items().suffix(from: 1).forEach { item in
                    remove(item)
                }
            }
            if items.count > 1 {
                perform(#selector(append(_:)), with: Array(items.suffix(from: 1)), afterDelay: 1, inModes: [.common])
            }
        }
        else {
            removeAllItems()
        }
    }

    @objc
    private func append(_ items: [AVPlayerItem]) {
        items.forEach { item in
            insert(item, after: nil)
        }
    }

    func cancelPendingReplacements() {
        RunLoop.cancelPreviousPerformRequests(withTarget: self)
    }

    private func configureChunkDurationPublisher() {
        chunkDurationPublisher()
            .assign(to: &$chunkDuration)
    }
}

extension Notification.Name {
    static let willSeek = Notification.Name("RawPlayerWillSeekNotification")
    static let didSeek = Notification.Name("RawPlayerDidSeekNotification")
}
