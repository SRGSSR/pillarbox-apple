//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public final class Player: ObservableObject {
    @Published public private(set) var state: State = .idle
    @Published public private(set) var progress: Float = 0

    let player: SystemPlayer
    private let queue = DispatchQueue(label: "ch.srgssr.pillarbox.player")

    public var items: [AVPlayerItem] {
        player.items()
    }

    public init(items: [AVPlayerItem] = []) {
        player = SystemPlayer(items: items)
        Self.statePublisher(for: player)
            .map { State(from: $0) }
            .removeDuplicates { State.areDuplicates($0, $1) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
        Self.progressPublisher(for: self, queue: queue)
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)
    }

    public convenience init(item: AVPlayerItem) {
        self.init(items: [item])
    }

    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        player.insert(item, after: afterItem)
    }

    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    public func remove(_ item: AVPlayerItem) {
        player.remove(item)
    }

    public func removeAllItems() {
        player.removeAllItems()
    }

    public func play() {
        player.play()
    }

    public func pause() {
        player.pause()
    }

    public func togglePlayPause() {
        if player.rate != 0 {
            player.pause()
        }
        else {
            player.play()
        }
    }

    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool {
        await player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }
}
