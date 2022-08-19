//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public final class Player: ObservableObject {
    @Published public private(set) var state: State = .idle
    @Published public private(set) var properties: Properties

    let systemPlayer: SystemPlayer

    public var items: [AVPlayerItem] {
        systemPlayer.items()
    }

    public init(items: [AVPlayerItem] = []) {
        systemPlayer = SystemPlayer(items: items)
        properties = .empty(for: systemPlayer)

        Self.statePublisher(for: self)
            .removeDuplicates(by: Self.areDuplicates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
        Self.propertiesPublisher(for: self)
            .receive(on: DispatchQueue.main)
            .assign(to: &$properties)
    }

    public convenience init(item: AVPlayerItem) {
        self.init(items: [item])
    }

    public func insert(_ item: AVPlayerItem, after afterItem: AVPlayerItem?) {
        systemPlayer.insert(item, after: afterItem)
    }

    public func append(_ item: AVPlayerItem) {
        insert(item, after: nil)
    }

    public func remove(_ item: AVPlayerItem) {
        systemPlayer.remove(item)
    }

    public func removeAllItems() {
        systemPlayer.removeAllItems()
    }

    public func play() {
        systemPlayer.play()
    }

    public func pause() {
        systemPlayer.pause()
    }

    public func togglePlayPause() {
        if systemPlayer.rate != 0 {
            systemPlayer.pause()
        }
        else {
            systemPlayer.play()
        }
    }

    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        systemPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }

    @discardableResult
    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) async -> Bool {
        await systemPlayer.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    static func areDuplicates(_ lhsState: State, _ rhsState: State) -> Bool {
        switch (lhsState, rhsState) {
        case (.idle, .idle),
            (.playing, .playing),
            (.paused, .paused),
            (.ended, .ended):
            return true
        default:
            return false
        }
    }
}
