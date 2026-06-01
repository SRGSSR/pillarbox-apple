//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import AVFoundation
import Combine
import PillarboxCore
import UIKit

#if DEBUG

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download: ObservableObject {
    private typealias DownloadPlayerProperties = DownloadProperties<PlayerMetadata>

    let id: String

    @Published private var properties: DownloadPlayerProperties = .init()

    private let trigger = Trigger()

    private let locationSubject = PassthroughSubject<URL?, Never>()
    private let errorSubject = PassthroughSubject<Error?, Never>()

    private let addRecord: () -> Void
    private let removeRecord: () -> Void

    public var progress: Double {
        properties.progress
    }

    public var state: DownloadState {
        properties.state
    }

    public var metadata: PlayerMetadata {
        properties.metadata ?? .empty
    }

    public var error: Error? {
        guard let error = properties.error else { return nil }
        return URLError.isCancellationError(error) ? nil : error
    }

    var fileUrl: URL? {
        properties.fileUrl
    }

    private init<L, S>(
        id: String,
        assetLoaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        self.id = id
        self.addRecord = {
            store.addDownloadRecord(using: input, forId: id)
        }
        self.removeRecord = {
            store.removeDownloadRecord(forId: id)
        }
        configurePropertiesPublisher(assetLoaderType: assetLoaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        assetLoaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        let id = type(of: store).id(from: input)
        store.addDownloadRecord(using: input, forId: id)
        self.init(id: id, assetLoaderType: assetLoaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        assetLoaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        self.init(id: type(of: store).id(from: record.input), assetLoaderType: assetLoaderType, input: record.input, session: session, store: store)
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func fail(with error: Error) {
        errorSubject.send(error)
        properties.source.cancel()
    }

    private func removeFile() {
        guard let fileUrl else { return }
        Task {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
}

@available(tvOS, unavailable)
public extension Download {
    func resume() {
        properties.source.resume()
    }

    func suspend() {
        properties.source.suspend()
    }

    func remove() {
        removeFile()
        cancelOperations()
        removeRecord()
    }

    func restart() {
        remove()
        addRecord()
        trigger.activate(for: TriggerId.reload)
    }

    private func cancelOperations() {
        properties.source.cancel()
        trigger.activate(for: TriggerId.cancel)
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case reload
        case cancel
    }

    static func metadataPublisher<L>(
        assetLoaderType: L.Type,
        input: L.Input,
        properties: DownloadProperties<L.Metadata>
    ) -> AnyPublisher<L.Metadata, Error> where L: AssetLoader {
        if let metadata = properties.metadata {
            return Just(metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else if properties.error == nil {
            return assetLoaderType.metadataPublisher(for: input)
                .first()
                .eraseToAnyPublisher()
        }
        else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

@available(tvOS, unavailable)
extension Download {
    private func configurePropertiesPublisher<L, S>(
        assetLoaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        downloadPropertiesPublisher(assetLoaderType: assetLoaderType, id: id, input: input, session: session, store: store)
            .receiveOnMainThread()
            .handleEvents(
                receiveOutput: { [id] properties in
                    let record = DownloadRecord(
                        input: input,
                        metadata: properties.metadata,
                        bookmarkData: properties.bookmarkData(),
                        progress: properties.progress,
                        error: properties.error
                    )
                    store.updateDownloadRecord(record, forId: id)
                },
                receiveCompletion: nil
            )
            .map { properties in
                DownloadProperties(
                    metadata: assetLoaderType.playerMetadata(from: input, metadata: properties.metadata),
                    source: properties.source,
                    fileUrl: properties.fileUrl,
                    error: properties.error
                )
            }
            .assign(to: &$properties)
    }

    private func downloadPropertiesPublisher<L, S>(
        assetLoaderType: L.Type,
        id: String,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) -> AnyPublisher<DownloadProperties<L.Metadata>, Never> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [trigger, locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Self.metadataPublisher(assetLoaderType: assetLoaderType, input: input, properties: properties)
                .receiveOnMainThread()
                .fail(onOutputFrom: trigger.signal(activatedBy: TriggerId.cancel), with: URLError(.cancelled))
                .map { metadata in
                    Publishers.CombineLatest3(
                        session.downloadSourcePublisher(
                            id: id,
                            asset: assetLoaderType.downloadableAsset(from: input, metadata: metadata),
                            title: assetLoaderType.playerMetadata(from: input, metadata: metadata).title,
                            createTaskIfNeeded: properties.shouldCreateTask,
                            progressEstimate: properties.progress
                        ),
                        locationSubject
                            .prepend(properties.fileUrl),
                        errorSubject
                            .prepend(properties.error)
                    )
                    .map { DownloadProperties(metadata: metadata, source: $0, fileUrl: $1, error: $2) }
                }
                .switchToLatest()
                .catch { Just(DownloadProperties(metadata: nil, source: .estimate(0), fileUrl: nil, error: $0)) }
                .prepend(properties)
        }
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
