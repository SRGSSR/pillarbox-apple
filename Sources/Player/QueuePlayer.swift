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

struct Seek: Equatable {
    let time: CMTime
    let toleranceBefore: CMTime
    let toleranceAfter: CMTime
    let isSmooth: Bool
    let completionHandler: (Bool) -> Void

    private let id = UUID()

    static func == (lhs: Seek, rhs: Seek) -> Bool {
        lhs.id == rhs.id
    }
}

class QueuePlayer: AVQueuePlayer {
    static let notificationCenter = NotificationCenter()

    private static var logger = Logger(category: "QueuePlayer")

    private var pendingSeeks = Deque<Seek>()
    private var cancellables = Set<AnyCancellable>()

    private var targetSeek: Seek? {
        pendingSeeks.last
    }

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

        let seek = Seek(
            time: time,
            toleranceBefore: toleranceBefore,
            toleranceAfter: toleranceAfter,
            isSmooth: smooth,
            completionHandler: completionHandler
        )
        pendingSeeks.append(seek)

        if smooth && pendingSeeks.count != 1 {
            return
        }

        enqueue(seek: seek) { [weak self] in
            guard let self else { return }
            self.notifySeekEnd()
        }
    }

    func enqueue(seek: Seek, completion: @escaping () -> Void) {
        super.seek(to: seek.time, toleranceBefore: seek.toleranceBefore, toleranceAfter: seek.toleranceAfter) { [weak self] finished in
            self?.process(seek: seek, finished: finished, completion: completion)
        }
    }

    private func process(seek: Seek, finished: Bool, completion: @escaping () -> Void) {
        if let targetSeek, seek != targetSeek {
            while let pendingSeek = pendingSeeks.first, pendingSeek != targetSeek {
                pendingSeeks.removeFirst()
                pendingSeek.completionHandler(targetSeek.isSmooth)
            }
            if finished {
                enqueue(seek: targetSeek, completion: completion)
            }
        }
        else if finished {
            completion()
            seek.completionHandler(finished)
            pendingSeeks.removeAll()
        }
        else {
            // Sometimes the target seek might fail for no reason, especially when seeking near the stream end.
            // In such cases retry.
            enqueue(seek: seek, completion: completion)
        }
    }

    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, completionHandler: completionHandler)
    }

    override func seek(to time: CMTime) {
        seek(to: time) { _ in }
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
                removeAll(from: 1)
                replaceCurrentItem(with: firstItem)
            }
            else {
                removeAll(from: 1)
            }
            if items.count > 1 {
                perform(#selector(append(_:)), with: Array(items.suffix(from: 1)), afterDelay: 1, inModes: [.common])
            }
        }
        else {
            removeAllItems()
        }
    }

    private func removeAll(from index: Int) {
        guard items().count > index else { return }
        items().suffix(from: index).forEach { item in
            remove(item)
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
        guard !pendingSeeks.isEmpty else { return }
        while let pendingSeek = pendingSeeks.popFirst() {
            pendingSeek.completionHandler(true)
        }
        notifySeekEnd()
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
