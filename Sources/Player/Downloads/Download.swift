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
    let id: String

    @Published private var properties: DownloadPlayerProperties = .empty

    private let trigger = Trigger()
    private let locationSubject = PassthroughSubject<URL, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()

    private let removeRecord: () -> Void
    private let resetRecord: () -> Void

    public var progress: Double? {
        switch state {
        case .running, .suspended:
            return properties.taskProperties?.progress ?? 0
        default:
            return nil
        }
    }

    public var state: DownloadState {
        properties.state
    }

    public var metadata: PlayerMetadata {
        properties.metadata
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
            store.updateDownloadRecord(record.reset())
        }
        configurePropertiesPublisher(loaderType: loaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        loaderType: L.Type,
        input: L.Input,
        session: AVAssetDownloadURLSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        let record = store.addDownloadRecord(using: input)
        self.init(id: record.id, loaderType: loaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        loaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        self.init(id: record.id, loaderType: loaderType, input: record.input, session: session, store: store)
    }

    func fileUrl(allowsPartial: Bool) -> URL? {
        properties.fileUrl(allowsPartial: allowsPartial)
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
        properties.taskProperties?.task.resume()
    }

    func suspend() {
        properties.taskProperties?.task.suspend()
    }

    func cancel() {
        removeRecord()
        removeFile()
        properties.taskProperties?.task.cancel()
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

    static func taskPropertiesPublisher(task: URLSessionTask?) -> AnyPublisher<TaskProperties?, Never> {
        guard let task else { return Just(nil).eraseToAnyPublisher() }
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
        let asset = loaderType.asset(input: input, metadata: metadata)
        let configuration = AVAssetDownloadConfiguration(
            asset: .init(url: asset.resource.url()),
            title: loaderType.playerMetadata(from: metadata).title ?? id
        )
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    static func taskPropertiesPublisher<L>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        metadata: L.Metadata,
        createIfNeeded: Bool,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<TaskProperties?, Never> where L: AssetLoader {
        session.taskPublisher(withDescription: id)
            .map { task in
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
            .map { taskPropertiesPublisher(task: $0) }
            .switchToLatest()
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
private extension Download {
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

    // swiftlint:disable:next function_body_length
    func propertiesPublisher<L, S>(
        loaderType: L.Type,
        id: String,
        input: L.Input,
        session: AVAssetDownloadURLSession,
        store: S
    ) -> AnyPublisher<DownloadPlayerProperties, Never> where L: AssetLoader, S: AssetDownloadStore, L.Input == S.Input, L.Metadata == S.Metadata {
        // swiftlint:disable:next closure_body_length
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Self.metadataPublisher(loaderType: loaderType, input: input, properties: properties)
                .map { metadata in
                    Publishers.CombineLatest4(
                        Just(metadata),
                        Self.taskPropertiesPublisher(
                            loaderType: loaderType,
                            id: id,
                            input: input,
                            metadata: metadata,
                            createIfNeeded: properties.isPreparing,
                            session: session
                        ),
                        locationSubject
                            .map(\.self)
                            .prepend(properties.location),
                        errorSubject
                            .map(\.self)
                            .prepend(properties.error)
                    )
                }
                .switchToLatest()
                .map { DownloadProperties(metadata: $0, taskProperties: $1, location: $2, error: $3) }
                .catch { error in
                    Just(DownloadProperties(metadata: nil, taskProperties: nil, location: nil, error: error))
                }
                .prepend(properties)
                .handleEvents(
                    receiveOutput: { properties in
                        let record = DownloadRecord(
                            id: id,
                            input: input,
                            metadata: properties.metadata,
                            bookmarkData: properties.bookmarkData(),
                            error: properties.error
                        )
                        store.updateDownloadRecord(record)
                    },
                    receiveCompletion: nil
                )
                .map { properties in
                    DownloadPlayerProperties(
                        metadata: loaderType.playerMetadata(from: properties.metadata),
                        taskProperties: properties.taskProperties,
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
