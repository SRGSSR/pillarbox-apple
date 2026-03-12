//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public final class Download: ObservableObject {
    let id: String
    public let title: String
    public let remoteUrl: URL
    private let task: URLSessionTask?
    private unowned let downloader: Downloader

    @Published private(set) var state: URLSessionTask.State = .completed
    @Published public private(set) var progress: Double = 1

    public var status: DownloadStatus {
        switch state {
        case .running:
            return .running
        case .suspended, .canceling:
            return .suspended
        case .completed:
            switch link() {
            case let .available(url):
                return .completed(url)
            case .missing:
                return .failed
            }
        @unknown default:
            return .failed
        }
    }

    private init(id: String, title: String, remoteUrl: URL, task: URLSessionTask?, downloader: Downloader) {
        self.id = id
        self.title = title
        self.remoteUrl = remoteUrl
        self.task = task
        self.downloader = downloader

        configureTaskPublisher()
    }

    func cancel() {
        task?.cancel()
    }

    func link() -> DownloadLink {
        downloader.link(for: self)
    }
}

private extension Download {
    static func downloadTask(id: String, title: String, remoteUrl: URL, downloader: Downloader) -> URLSessionTask {
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: remoteUrl), title: title)
        let task = downloader.session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        return task
    }

    func configureTaskPublisher() {
        task?.publisher(for: \.state)
            .receiveOnMainThread()
            .assign(to: &$state)

        task?.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .receiveOnMainThread()
            .assign(to: &$progress)
    }
}

extension Download {
    convenience init(metadata: DownloadMetadata, task: URLSessionTask?, downloader: Downloader) {
        self.init(id: metadata.id, title: metadata.title, remoteUrl: metadata.remoteUrl, task: task, downloader: downloader)
    }

    convenience init(title: String, remoteUrl: URL, downloader: Downloader) {
        let id = UUID().uuidString
        let task = Self.downloadTask(id: id, title: title, remoteUrl: remoteUrl, downloader: downloader)
        self.init(id: id, title: title, remoteUrl: remoteUrl, task: task, downloader: downloader)
    }
}

public extension Download {
    func resume() {
        task?.resume()
    }

    func suspend() {
        task?.suspend()
    }

    func restart() -> Download {
        downloader.restart(download: self)
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
