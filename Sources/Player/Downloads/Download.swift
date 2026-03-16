//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import UIKit

public final class Download: ObservableObject {
    private let id: String

    public let title: String
    public let url: URL

    private var task: URLSessionTask? {
        didSet {
            configureTaskPublishers()
        }
    }

    private weak let session: AVAssetDownloadURLSession?

    @Published public private(set) var state: URLSessionTask.State = .completed
    @Published public private(set) var progress: Double = 1

    @Published private var bookmarkData: Data?
    @Published private var error: Error?

    private var locationSubject = CurrentValueSubject<URL?, Never>(nil)
    private var cancellables = Set<AnyCancellable>()

    public var file: DownloadedFile {
        guard error == nil else { return .failed }
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

    private init(id: String, title: String, url: URL, bookmarkData: Data?, task: URLSessionTask?, session: AVAssetDownloadURLSession) {
        self.id = id
        self.title = title
        self.url = url
        self.bookmarkData = bookmarkData
        self.task = task
        self.session = session

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        configureTaskPublishers()
    }

    convenience init(title: String, url: URL, using session: AVAssetDownloadURLSession) {
        let id = UUID().uuidString
        let task = Self.task(id: id, title: title, url: url, using: session)
        self.init(id: id, title: title, url: url, bookmarkData: nil, task: task, session: session)
    }

    convenience init(from metadata: DownloadMetadata, reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) {
        if let bookmarkData = metadata.bookmarkData {
            let task = tasks.first { $0.taskDescription == metadata.id }
            task?.resume()
            self.init(id: metadata.id, title: metadata.title, url: metadata.url, bookmarkData: bookmarkData, task: task, session: session)
        }
        else {
            self.init(title: metadata.title, url: metadata.url, using: session)
        }
    }

    static func task(id: String, title: String, url: URL, using session: AVAssetDownloadURLSession?) -> URLSessionTask? {
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

    func metadata() -> DownloadMetadata {
        .init(id: id, title: title, url: url, bookmarkData: bookmarkData)
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
        self.error = error
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
            .weakAssign(to: \.progress, on: self)
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
    func applicationWillTerminate() {
        guard bookmarkData == nil else { return }
        task?.cancel()
    }
}

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
        error = nil
    }
}

extension Download: Hashable {
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
