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
    private let id = UUID()

    public var title: String {
        metadata.title ?? "-"
    }

    private var task: URLSessionTask? {
        didSet {
            configureTaskPublishers()
        }
    }

    private weak let session: AVAssetDownloadURLSession?

    public var metadata: PlayerMetadata {
        content.metadata
    }

    public var progress: Double {
        hasFailed ? 0 : _progress
    }

    @Published private var content: AssetContent
    @Published public private(set) var state: URLSessionTask.State = .completed
    @Published private var _progress: Double = 1

    @Published private var hasFailed = false {
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
            return .partial(.simple(url: url, metadata: downloadMetadata()))
        case .completed:
            guard let url = fileUrl() else { return .failed }
            return .complete(.simple(url: url, metadata: downloadMetadata()))
        @unknown default:
            return .failed
        }
    }

    init<P, M>(
        publisher: P,
        metadataMapper: @escaping (M) -> PlayerMetadata,
        using session: AVAssetDownloadURLSession
    ) where P: Publisher, P.Output == Asset<M> {
        self.content = .loading(id: id)
        self.session = session

        publisher
            .map { [id] asset in
                .loaded(id: id, resource: asset.resource, metadata: metadataMapper(asset.metadata), configuration: asset.configuration, dateInterval: nil)
            }
            .catch { [id] error in
                Just(.failing(id: id, error: error))
            }
            .assign(to: &$content)
    }

    convenience init<M>(asset: Asset<M>, using session: AVAssetDownloadURLSession) where M: AssetMetadata {
        self.init(publisher: Just(asset), metadataMapper: { $0.playerMetadata }, using: session)
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id.uuidString
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

    func downloadMetadata() -> DownloadMetadata {
        .init(id: id, playerMetadata: content.metadata, url: nil /* FIXME */, bookmarkData: bookmarkData, hasFailed: hasFailed)
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

        // FIXME:
        // task = ...
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
