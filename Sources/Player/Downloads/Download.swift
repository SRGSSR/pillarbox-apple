//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import AVFoundation
import Combine
import PillarboxCore
import UIKit

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download: ObservableObject {
    private typealias DownloadPlayerProperties = DownloadProperties<Void>

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
        properties.source.metadata?.playerMetadata ?? .empty
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
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
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
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        let id = type(of: store).id(from: input)
        store.addDownloadRecord(using: input, forId: id)
        self.init(id: id, assetLoaderType: assetLoaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        assetLoaderType: L.Type,
        record: DownloadRecord<S.Loader.Input, S.CustomData>,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        self.init(
            id: type(of: store).id(from: record.input),
            assetLoaderType: assetLoaderType,
            input: record.input,
            session: session,
            store: store
        )
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

    static func downloadSourcePublisher<L, S>(
        assetLoaderType: L.Type,
        storeType: S.Type,
        id: String,
        input: L.Input,
        session: DownloadSession,
        properties: DownloadProperties<S.CustomData>
    ) -> AnyPublisher<DownloadSource<S.CustomData>, Error> where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        if !properties.shouldCreateTask, let metadata = properties.source.metadata {
            return session.sessionTaskPublisher(id: id)
                .setFailureType(to: Error.self)
                .map { session.downloadSessionTaskPropertiesPublisher(for: $0) }
                .switchToLatest()
                .map { .init(kind: .task($0), metadata: metadata) }
                .prepend(.init(kind: .estimate(properties.progress), metadata: metadata))
                .eraseToAnyPublisher()
        }
        else {
            return assetLoaderType.metadataPublisher(for: input)
                .first()
                .map { metadata in
                    let playerMetadata = assetLoaderType.playerMetadata(from: input, metadata: metadata)
                    let task = session.createTask(
                        id: id,
                        asset: assetLoaderType.downloadableAsset(from: input, metadata: metadata),
                        title: playerMetadata.title
                    )
                    return Publishers.CombineLatest(
                        session.downloadSessionTaskPropertiesPublisher(for: task),
                        Just(AssetMetadata(playerMetadata: playerMetadata, customData: S.customData(from: metadata)))
                    )
                }
                .switchToLatest()
                .map { .init(kind: .task($0), metadata: $1) }
                .prepend(.init(kind: .estimate(0), metadata: nil))
                .eraseToAnyPublisher()
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
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        downloadPropertiesPublisher(assetLoaderType: assetLoaderType, id: id, input: input, session: session, store: store)
            .receiveOnMainThread()
            .handleEvents(
                receiveOutput: { [id] properties in
                    let record = DownloadRecord(
                        input: input,
                        metadata: properties.source.metadata,
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
                    source: .init(
                        kind: properties.source.kind,
                        metadata: properties.source.metadata?.withoutCustomData()
                    ),
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
    ) -> AnyPublisher<DownloadProperties<S.CustomData>, Never> where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [trigger, locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Publishers.CombineLatest3(
                Self.downloadSourcePublisher(
                    assetLoaderType: assetLoaderType,
                    storeType: type(of: store),
                    id: id,
                    input: input,
                    session: session,
                    properties: properties
                ),
                locationSubject
                    .setFailureType(to: Error.self)
                    .prepend(properties.fileUrl),
                errorSubject
                    .setFailureType(to: Error.self)
                    .prepend(properties.error)
            )
            .map { DownloadProperties(source: $0, fileUrl: $1, error: $2) }
            .fail(onOutputFrom: trigger.signal(activatedBy: TriggerId.cancel), with: URLError(.cancelled))
            .catch { Just(DownloadProperties(source: .init(kind: .estimate(0), metadata: nil), fileUrl: nil, error: $0)) }
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
