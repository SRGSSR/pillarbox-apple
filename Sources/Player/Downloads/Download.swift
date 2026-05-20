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
        session: AVAssetDownloadURLSession,
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
        session: AVAssetDownloadURLSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        let id = type(of: store).id(from: input)
        store.addDownloadRecord(using: input, forId: id)
        self.init(id: id, loaderType: loaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        loaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession,
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
        properties.job.resume()
    }

    func suspend() {
        properties.job.suspend()
    }

    func cancel() {
        removeRecord()
        removeFile()
        properties.job.cancel()
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

    static func downloadTaskPropertiesPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadTaskProperties, Never> {
        return Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map { .init(task: $0, state: $1, progress: $2) }
        .eraseToAnyPublisher()
    }
}

@available(tvOS, unavailable)
private extension Download {
    static func task<L>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        metadata: L.Metadata,
        using session: AVAssetDownloadURLSession
    ) -> URLSessionTask where L: AssetLoader {
        let asset = loaderType.downloadableAsset(input: input, metadata: metadata)
        let configuration = AVAssetDownloadConfiguration(
            asset: asset.urlAsset(),
            title: loaderType.playerMetadata(from: metadata).title ?? id
        )
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    static func downloadJobPublisher<L>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        metadata: L.Metadata,
        lastKnownProgress: Double,
        createIfNeeded: Bool,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<DownloadJob, Never> where L: AssetLoader {
        session.taskPublisher(withDescription: id)
            .compactMap { task in
                if let task {
                    return task
                }
                else if createIfNeeded {
                    return Self.task(loaderType: loaderType, id: id, input: input, metadata: metadata, using: session)
                }
                else {
                    return nil
                }
            }
            .map { downloadTaskPropertiesPublisher(for: $0) }
            .switchToLatest()
            .map { .task(properties: $0) }
            .prepend(.none(estimatedProgress: lastKnownProgress))
            .eraseToAnyPublisher()
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
        else {
            return loaderType.metadataPublisher(for: input)
        }
    }
}

@available(tvOS, unavailable)
extension Download {
    private func configurePropertiesPublisher<L, S>(
        loaderType: L.Type,
        input: L.Input,
        session: AVAssetDownloadURLSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        propertiesPublisher(loaderType: loaderType, id: id, input: input, session: session, store: store)
            .receiveOnMainThread()
            .assign(to: &$properties)
    }

    private func propertiesPublisher<L, S>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        session: AVAssetDownloadURLSession,
        store: S
    ) -> AnyPublisher<DownloadPlayerProperties, Never> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Self.metadataPublisher(loaderType: loaderType, input: input, properties: properties)
                .map { metadata in
                    Publishers.CombineLatest3(
                        Self.downloadJobPublisher(
                            loaderType: loaderType,
                            id: id,
                            input: input,
                            metadata: metadata,
                            lastKnownProgress: properties.progress,
                            createIfNeeded: properties.shouldCreateJob,
                            session: session
                        ),
                        locationSubject
                            .map(\.self)
                            .prepend(properties.location),
                        errorSubject
                            .map(\.self)
                            .prepend(properties.error)
                    )
                    .map { DownloadProperties(metadata: metadata, job: $0, location: $1, error: $2) }
                }
                .switchToLatest()
                .catch { error in
                    Just(DownloadProperties(metadata: nil, job: .none(estimatedProgress: 0), location: nil, error: error))
                }
                .prepend(properties)
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
                        job: properties.job,
                        location: properties.location,
                        error: properties.error
                    )
                }
                .eraseToAnyPublisher()
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
