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

protocol DownloadDelegate<Metadata>: AnyObject {
    associatedtype Metadata

    func didProvideMetadata(_ metadata: Metadata, for identifier: String)
    func didProvideBookmarkData(_ bookmarkData: Data, for identifier: String)
}

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download<L>: ObservableObject where L: AssetLoader {
    let id: String
    let loaderType: L.Type

    private weak let delegate: (any DownloadDelegate<L.Metadata>)?

    @Published private var _metadata: L.Metadata?

    // FIXME:
    @Published public private(set) var progress: Double = 1
    @Published public private(set) var state: URLSessionTask.State = .completed

    public var file: DownloadedFile {
        // FIXME:
        .failed
    }

    init(
        id: String,
        loaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession,
        tasks: [URLSessionTask] = [],
        delegate: any DownloadDelegate<L.Metadata>
    ) {
        self.id = id
        self.loaderType = loaderType
        self.delegate = delegate
        configureMetadataPublisher(for: record)
    }

    public func metadata() -> PlayerMetadata {
        guard let _metadata else { return .empty}
        return loaderType.playerMetadata(from: _metadata)
    }

    func attach(to location: URL) {
    }

    func complete(with error: Error?) {
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
    }

    private func configureMetadataPublisher(for record: DownloadRecord<L.Input, L.Metadata>) {
        metadataPublisher(for: record)
            .assign(to: &$_metadata)
    }

    private func metadataPublisher(for record: DownloadRecord<L.Input, L.Metadata>) -> AnyPublisher<L.Metadata?, Never> {
        if let metadata = record.metadata {
            return Just(metadata).eraseToAnyPublisher()
        }
        else {
            return loaderType.metadataPublisher(for: record.input)
                .handleEvents(receiveOutput: { [id, delegate] metadata in
                    delegate?.didProvideMetadata(metadata, for: id)
                }, receiveCompletion: nil)
                .map(\.self)
                .replaceError(with: nil)        // FIXME: Error management
                .eraseToAnyPublisher()
        }
    }
}

@available(tvOS, unavailable)
public extension Download {
    func resume() {
    }

    func suspend() {
    }

    func cancel() {
    }

    func restart() {
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
