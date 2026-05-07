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
public final class Download<L, S>: ObservableObject where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
    private let id: String

    @Published private(set) var record: DownloadRecord<S.Input, S.Metadata> {
        didSet {
            if let bookmarkData = record.bookmarkData {
                downloader?.updateDownloadRecord(bookmarkData: bookmarkData, for: id)
            }
        }
    }

    private var task: URLSessionTask? {
        didSet {
            configureTaskPublishers()
        }
    }

    private weak let session: AVAssetDownloadURLSession?
    private weak let downloader: S?

    public var progress: Double {
        hasFailed ? 0 : _progress
    }

    @Published public private(set) var state: URLSessionTask.State = .completed
    @Published private var _progress: Double = 1

    @Published private var hasFailed: Bool

    private let locationSubject = CurrentValueSubject<URL?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    public var file: DownloadedFile {
        guard !hasFailed else { return .failed }
        switch state {
        case .running, .suspended, .canceling:
            guard let url = fileUrl() else { return .unavailable }
            return .partial(url)
        case .completed:
            guard let url = fileUrl() else { return .failed }
            return .complete(url)
        @unknown default:
            return .failed
        }
    }

    private init(id: String, record: DownloadRecord<S.Input, S.Metadata>, store: S, task: URLSessionTask?, session: AVAssetDownloadURLSession) {
        self.id = id
        self.record = record
        self.hasFailed = false
        self.task = task
        self.session = session
        self.downloader = store

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        configureTaskPublishers()
    }

    convenience init(loaderType: L.Type, from input: S.Input, store: S, using session: AVAssetDownloadURLSession) {
        let id = store.identifier(for: input)
        let record = store.downloadRecord(for: id) ?? store.addDownloadRecord(using: input, for: id)
        self.init(id: id, record: record, store: store, task: nil, session: session)
        loaderType.assetPublisher(for: input)
            .handleEvents(receiveOutput: { asset in
                store.updateDownloadRecord(metadata: asset.metadata, for: id)
            }, receiveCompletion: nil)
            .map { asset in
                let title = loaderType.playerMetadata(from: asset.metadata).title
                let url = asset.resource.url()
                return Self.task(id: id, title: title ?? id, url: url, using: session)
            }
            .catch { _ in
                Just(nil).eraseToAnyPublisher()
            }
            .weakAssign(to: \.task, on: self)
            .store(in: &cancellables)
    }

    convenience init(
        loaderType: L.Type,
        from record: DownloadRecord<S.Input, S.Metadata>,
        store: S,
        reusing tasks: [URLSessionTask],
        in session: AVAssetDownloadURLSession
    ) {
        let id = store.identifier(for: record.input)
        if record.bookmarkData != nil {
            self.init(
                id: id,
                record: record,
                store: store,
                task: tasks.first { $0.taskDescription == id },
                session: session
            )
        }
        else {
            self.init(loaderType: loaderType, from: record.input, store: store, using: session)
        }
    }

    private static func task(id: String, title: String, url: URL, using session: AVAssetDownloadURLSession?) -> URLSessionTask? {
        guard let session else { return nil }
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
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
        guard let bookmarkData = record.bookmarkData else { return nil }
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
            .weakAssign(to: \.record.bookmarkData, on: self)
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
        guard record.bookmarkData == nil else { return }
        task?.cancel()
    }

    public func metadata() -> PlayerMetadata {
        guard let metadata = record.metadata else { return .empty }
        return L.playerMetadata(from: metadata)
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

        // TODO: We have to handle the restart.
        // task = Self.task(id: id, title: title, url: url, using: session)
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
