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

    private let locationSubject = PassthroughSubject<URL, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()

    private let removeRecord: () -> Void
    private let resetRecord: () -> Void

    public var progress: Double {
        properties.progress
    }

    public var state: DownloadState {
        properties.state
    }

    public var metadata: PlayerMetadata {
        properties.metadata ?? .empty
    }

    var location: URL? {
        properties.location
    }

    private init<L, S>(
        id: String,
        loaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        self.id = id
        self.removeRecord = {
            store.removeDownloadRecord(forId: id)
        }
        self.resetRecord = {
            guard let record = store.downloadRecord(forId: id) else { return }
            store.updateDownloadRecord(record.reset(), forId: id)
        }
        configurePropertiesPublisher(loaderType: loaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        loaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        let id = type(of: store).id(from: input)
        store.addDownloadRecord(using: input, forId: id)
        self.init(id: id, loaderType: loaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        loaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        self.init(id: type(of: store).id(from: record.input), loaderType: loaderType, input: record.input, session: session, store: store)
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func fail(with error: Error) {
        errorSubject.send(error)
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
    }

    private func removeFile() {
        guard let location = properties.location else { return }
        try? FileManager.default.removeItem(at: location)
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

    func cancel() {
        removeRecord()
        removeFile()
        properties.source.cancel()
    }

    func restart() {
        resetRecord()
        removeFile()
        trigger.activate(for: TriggerId.reload)
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case reload
    }

    static func metadataPublisher<L>(
        loaderType: L.Type,
        input: L.Input,
        properties: DownloadProperties<L.Metadata>
    ) -> AnyPublisher<L.Metadata, Error> where L: AssetLoader {
        if let metadata = properties.metadata {
            return Just(metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else if properties.error == nil {
            return loaderType.metadataPublisher(for: input)
        }
        else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

@available(tvOS, unavailable)
extension Download {
    private func configurePropertiesPublisher<L, S>(
        loaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        downloadPlayerPropertiesPublisher(loaderType: loaderType, id: id, input: input, session: session, store: store)
            .receiveOnMainThread()
            .assign(to: &$properties)
    }

    private func downloadPropertiesPublisher<L, S>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) -> AnyPublisher<DownloadProperties<L.Metadata>, Never> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Self.metadataPublisher(loaderType: loaderType, input: input, properties: properties)
                .map { metadata in
                    Publishers.CombineLatest3(
                        session.downloadSourcePublisher(
                            id: id,
                            asset: loaderType.downloadableAsset(input: input, metadata: metadata),
                            title: loaderType.playerMetadata(from: metadata).title,
                            createTaskIfNeeded: properties.shouldCreateTask,
                            progressEstimate: properties.progress
                        ),
                        locationSubject
                            .map(\.self)
                            .prepend(properties.location),
                        errorSubject
                            .map(\.self)
                            .prepend(properties.error)
                    )
                    .map { DownloadProperties(metadata: metadata, source: $0, location: $1, error: $2) }
                }
                .switchToLatest()
                .catch { error in
                    Just(DownloadProperties(metadata: nil, source: .estimate(0), location: nil, error: error))
                }
                .prepend(properties)
        }
    }

    private func downloadPlayerPropertiesPublisher<L, S>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) -> AnyPublisher<DownloadPlayerProperties, Never> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        downloadPropertiesPublisher(loaderType: loaderType, id: id, input: input, session: session, store: store)
            .handleEvents(
                receiveOutput: { properties in
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
                    metadata: loaderType.playerMetadata(from: properties.metadata),
                    source: properties.source,
                    location: properties.location,
                    error: properties.error
                )
            }
            .eraseToAnyPublisher()
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
