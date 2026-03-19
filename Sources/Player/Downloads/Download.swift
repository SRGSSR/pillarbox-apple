//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import AVFoundation
import Combine
import UIKit

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download: ObservableObject {
    private let id: UUID

    public let title: String
    public let url: URL

    private var task: URLSessionTask? {
        didSet {
            configureTaskPublishers()
        }
    }

    private weak let session: AVAssetDownloadURLSession?

    public var progress: Double {
        hasFailed ? 0 : _progress
    }

    @Published public private(set) var state: URLSessionTask.State = .completed
    @Published private var _progress: Double = 1

    @Published private var hasFailed: Bool {
        didSet {
            notifyUpdate()
        }
    }

    @Published private var bookmarkData: Data? {
        didSet {
            notifyUpdate()
        }
    }

    private let locationSubject = CurrentValueSubject<URL?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    public var file: DownloadedFile {
        guard !hasFailed else { return .failed }
        switch state {
        case .running, .suspended, .canceling:
            guard let url = fileUrl() else { return .unavailable }
            return .partial(.simple(url: url, metadata: metadata()))
        case .completed:
            guard let url = fileUrl() else { return .failed }
            return .complete(.simple(url: url, metadata: metadata()))
        @unknown default:
            return .failed
        }
    }

    private init(id: UUID, title: String, url: URL, bookmarkData: Data?, hasFailed: Bool, task: URLSessionTask?, session: AVAssetDownloadURLSession) {
        self.id = id
        self.title = title
        self.url = url
        self.bookmarkData = bookmarkData
        self.hasFailed = hasFailed
        self.task = task
        self.session = session

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        configureTaskPublishers()
    }

    convenience init(title: String, url: URL, using session: AVAssetDownloadURLSession) {
        let id = UUID()
        let task = Self.task(id: id, title: title, url: url, using: session)
        self.init(id: id, title: title, url: url, bookmarkData: nil, hasFailed: false, task: task, session: session)
    }

    convenience init(from metadata: DownloadMetadata, reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) {
        if let bookmarkData = metadata.bookmarkData {
            self.init(
                id: metadata.id,
                title: metadata.title,
                url: metadata.url,
                bookmarkData: bookmarkData,
                hasFailed: metadata.hasFailed,
                task: tasks.first { $0.taskDescription == metadata.id.uuidString },
                session: session
            )
        }
        else {
            self.init(title: metadata.title, url: metadata.url, using: session)
        }
    }

    private static func task(id: UUID, title: String, url: URL, using session: AVAssetDownloadURLSession?) -> URLSessionTask? {
        guard let session else { return nil }
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id.uuidString
        task.resume()
        return task
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id.uuidString
    }

    func metadata() -> DownloadMetadata {
        .init(id: id, title: title, url: url, bookmarkData: bookmarkData, hasFailed: hasFailed)
    }

    func cancel() {
        task?.cancel()
        removeFile()
    }

    func removeFile() {
        if let url = fileUrl() {
            try? FileManager.default.removeItem(at: url)
        }
        if let url = locationUrl() {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func complete(with error: Error?) {
        hasFailed = error != nil
    }

    private func fileUrl() -> URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    }

    private func locationUrl() -> URL? {
        locationSubject.value
    }

    private func configureTaskPublishers() {
        cancellables = []
        guard let task else { return }
        task.publisher(for: \.state)
            .receiveOnMainThread()
            .weakAssign(to: \.state, on: self)
            .store(in: &cancellables)
        task.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .weakAssign(to: \._progress, on: self)
            .store(in: &cancellables)
        bookmarkDataPublisher(for: task)
            .receiveOnMainThread()
            .map { Optional($0) }
            .weakAssign(to: \.bookmarkData, on: self)
            .store(in: &cancellables)
    }

    private func bookmarkDataPublisher(for task: URLSessionTask) -> AnyPublisher<Data, Never> {
        locationSubject.map { url in
            task.progress.publisher(for: \.fractionCompleted)
                .first { $0 > 0 }
                .compactMap { _ in try? url?.bookmarkData() }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }

    @objc
    private func applicationWillTerminate() {
        guard bookmarkData == nil else { return }
        task?.cancel()
    }

    private func notifyUpdate() {
        NotificationCenter.default.post(name: .didUpdateDownload, object: self)
    }
}

@available(tvOS, unavailable)
public extension Download {
    func resume() {
        task?.resume()
    }

    func suspend() {
        task?.suspend()
    }

    func restart() {
        removeFile()

        task = Self.task(id: id, title: title, url: url, using: session)
        hasFailed = false
    }
}

@available(tvOS, unavailable)
extension Download: Hashable {
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

#endif

// swiftlint:enable missing_docs
