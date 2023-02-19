//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule
import OSLog

enum SeekKey: String {
    case time
}

private struct Seek {
    let time: CMTime
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void
}

final class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private static var logger = Logger(category: "QueuePlayer")

    private var targetSeek: Seek?
    private var pendingSeeks = Deque<Seek>()
    private var cancellables = Set<AnyCancellable>()

    var targetSeekTime: CMTime? {
        targetSeek?.time
    }

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, smooth: false, completionHandler: completionHandler)
    }

    func seek(
        to time: CMTime,
        toleranceBefore: CMTime = .positiveInfinity,
        toleranceAfter: CMTime = .positiveInfinity,
        smooth: Bool,
        completionHandler: @escaping (Bool) -> Void
    ) {
        assert(time.isValid)

        guard !items().isEmpty else {
            completionHandler(true)
            return
        }

        registerSentinels()
        notifySeekStart(at: time)

        if let targetSeek {
            pendingSeeks.append(targetSeek)
        }
        let seek = Seek(time: time, isSmooth: smooth, completionHandler: completionHandler)
        targetSeek = seek

        if smooth && !pendingSeeks.isEmpty {
            return
        }

        move(to: seek, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] _ in
            self?.notifySeekEnd()
        }
    }

    private func move(to seek: Seek, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: seek.time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter) { [weak self] finished in
            self?.processSeek(
                at: seek.time,
                toleranceBefore: toleranceBefore,
                toleranceAfter: toleranceAfter,
                finished: finished,
                completionHandler: completionHandler
            )
        }
    }

    private func processSeek(
        at time: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        finished: Bool,
        completionHandler: @escaping (Bool) -> Void
    ) {
        while let pendingSeek = pendingSeeks.popFirst() {
            pendingSeek.completionHandler(finished)
        }
        guard let targetSeek else {
            completionHandler(finished)
            return
        }
        if targetSeek.time == time {
            targetSeek.completionHandler(true)
            completionHandler(true)
            self.targetSeek = nil
        }
        else if targetSeek.isSmooth {
            move(
                to: targetSeek,
                toleranceBefore: toleranceBefore,
                toleranceAfter: toleranceAfter,
                completionHandler: completionHandler
            )
        }
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        self.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, completionHandler: completionHandler)
    }

    override func seek(to time: CMTime) {
        self.seek(to: time) { _ in }
    }

    private func notifySeekStart(at time: CMTime) {
        Self.notificationCenter.post(name: .willSeek, object: self, userInfo: [SeekKey.time: time])
    }

    private func notifySeekEnd() {
        Self.notificationCenter.post(name: .didSeek, object: self)
    }
}

extension AVQueuePlayer {
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
}

extension QueuePlayer {
    /// Returns a publisher which emits a value when an incorrect start time is detected for the provided item.
    private static func incorrectStartTimeDetectionPublisher(for item: AVPlayerItem) -> AnyPublisher<Void, Never> {
        Publishers.CombineLatest(
            Just(item.currentTime()),
            item.durationPublisher()
        )
        .filter { currentTime, duration in
            duration.isValid && !duration.isIndefinite && CMTimeAbsoluteValue(currentTime) > CMTime(value: 1, timescale: 1)
        }
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private func registerSentinels() {
        guard cancellables.isEmpty else { return }

        // Workaround for `AVQueuePlayer` bug which, in some cases, might never call a pending seek completion handler
        // when transitioning between two items. We can use a sentinel to fix this behavior and ensure we always can
        // reliably match a seek request with a completion.
        publisher(for: \.currentItem)
            .sink { [weak self] _ in
                self?.processPendingSeeks()
            }
            .store(in: &cancellables)

        // Workaround for `AVQueuePlayer` bug which sometimes apply the previous current time to a newly loaded item.
        publisher(for: \.currentItem)
            .dropFirst()
            .compactMap { $0 }
            .map { Self.incorrectStartTimeDetectionPublisher(for: $0) }
            .switchToLatest()
            .sink { [weak self] _ in
                self?.rawSeek(to: .zero)
                Self.logger.info("Sentinel detected an incorrect start position and fixed it")
            }
            .store(in: &cancellables)
    }

    private func processPendingSeeks() {
        guard let targetSeek = self.targetSeek else { return }
        while let pendingSeek = self.pendingSeeks.popFirst() {
            pendingSeek.completionHandler(true)
        }
        targetSeek.completionHandler(true)
        self.targetSeek = nil
        self.notifySeekEnd()
        Self.logger.info("Sentinel detected unhandled completion and fixed it")
    }

    /// Perform a low-level seek without seek tracking.
    private func rawSeek(to time: CMTime) {
        super.seek(to: time)
    }
}

extension Notification.Name {
    static let willSeek = Notification.Name("QueuePlayerWillSeekNotification")
    static let didSeek = Notification.Name("QueuePlayerDidSeekNotification")
}
