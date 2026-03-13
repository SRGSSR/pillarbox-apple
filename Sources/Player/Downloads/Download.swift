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
            configureTaskPublisher()
        }
    }

    @Published private(set) var state: URLSessionTask.State = .completed
    @Published public private(set) var progress: Double = 0

    private var locationSubject = PassthroughSubject<URL, Never>()

    private var bookmarkData: Data?
    public var status: DownloadStatus = .suspended

    private init(id: String, title: String, url: URL, bookmarkData: Data?, task: URLSessionTask?) {
        self.id = id
        self.title = title
        self.url = url
        self.bookmarkData = bookmarkData
        self.task = task

        NotificationCenter.default.addObserver(self, selector: #selector(cleanup(_:)), name: UIApplication.willTerminateNotification, object: nil)
        configureTaskPublisher()
    }

    static func create(title: String, url: URL, using session: AVAssetDownloadURLSession) -> Self {
        let id = UUID().uuidString
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: url), title: title)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        return self.init(id: id, title: title, url: url, bookmarkData: nil, task: task)
    }

    static func restore(from metadata: DownloadMetadata, reusing tasks: [URLSessionTask], in session: AVAssetDownloadURLSession) -> Self {
        if let bookmarkData = metadata.bookmarkData {
            let task = tasks.first(where: { $0.taskDescription == metadata.id })
            return self.init(id: metadata.id, title: metadata.title, url: metadata.url, bookmarkData: bookmarkData, task: task)
        }
        else {
            return create(title: metadata.title, url: metadata.url, using: session)
        }
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
    }

    func metadata() -> DownloadMetadata {
        .init(id: id, title: title, url: url, bookmarkData: bookmarkData)
    }

    @objc
    func cleanup(_ notification: Notification) {
        guard bookmarkData == nil else { return }
        task?.cancel()
    }

    func cancel() {
        task?.cancel()
        if let url = fileUrl() {
            try? FileManager.default.removeItem(at: url)
        }
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    private func fileUrl() -> URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    }

    private func configureTaskPublisher() {

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
