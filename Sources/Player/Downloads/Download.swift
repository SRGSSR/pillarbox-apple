//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

public final class Download: ObservableObject {
    private let id: String

    public let title: String
    public let url: URL

    private var task: URLSessionTask? {
        didSet {
            configureTaskPublisher()
        }
    }

    @Published private var location: DownloadLocation = .unknown

    @Published private(set) var state: URLSessionTask.State = .completed
    @Published public private(set) var progress: Double = 1

    public var status: DownloadStatus {
        switch state {
        case .running:
            return .running
        case .suspended, .canceling:
            return .suspended
        case .completed:
            if let url = fileUrl() {
                return .completed(url)
            }
            else {
                return .failed
            }
        @unknown default:
            return .failed
        }
    }

    private init(id: String, title: String, url: URL, location: DownloadLocation, task: URLSessionTask?) {
        self.id = id
        self.title = title
        self.url = url
        self.location = location
        self.task = task

        configureTaskPublisher()
    }

    static func create(title: String, url: URL, using session: AVAssetDownloadURLSession) -> Self {
        let id = UUID().uuidString
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        return self.init(id: id, title: title, url: url, location: .unknown, task: task)
    }

    static func restore(from metadata: DownloadMetadata, reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) -> Self {
        if let task = tasks.first(where: { $0.taskDescription == metadata.id }) {
            return self.init(id: metadata.id, title: metadata.title, url: metadata.url, location: .init(from: metadata.bookmarkData), task: task)
        }
        else if let bookmarkData = metadata.bookmarkData {
            return self.init(id: metadata.id, title: metadata.title, url: metadata.url, location: .bookmark(bookmarkData), task: nil)
        }
        else {
            return create(title: metadata.title, url: metadata.url, using: session)
        }
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
    }

    func metadata() -> DownloadMetadata {
        .init(id: id, title: title, url: url, bookmarkData: location.bookmarkData())
    }

    func attach(to url: URL) {
        location = .unreliable(url)
    }

    func cancel() {
        task?.cancel()
        if let url = fileUrl() {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func configureTaskPublisher() {
        guard let task else { return }
        task.publisher(for: \.state)
            .receiveOnMainThread()
            .assign(to: &$state)
        task.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .assign(to: &$progress)
        Publishers.CombineLatest(task.publisher(for: \.state), $location)
            .compactMap { _, location in
                location.toBookmark()
            }
            .assign(to: &$location)
    }

    private func fileUrl() -> URL? {
        guard let bookmarkData = location.bookmarkData() else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
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
