//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

import Combine
import Foundation
import PillarboxCore

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

    public let creationDate: Date

    public var progress: Double {
        properties.fractionCompleted
    }

    public var state: DownloadState {
        properties.state
    }

    public var metadata: PlayerMetadata {
        properties.assetMetadata?.playerMetadata ?? .empty
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
        creationDate: Date,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        self.id = id
        self.creationDate = creationDate
        self.addRecord = {
            store.addDownloadRecord(.init(input: input, creationDate: creationDate), forId: id)
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
        let id = S.id(from: input)
        let creationDate = Date.now
        store.addDownloadRecord(.init(input: input, creationDate: creationDate), forId: id)
        self.init(id: id, assetLoaderType: assetLoaderType, input: input, creationDate: creationDate, session: session, store: store)
    }

    convenience init<L, S>(
        assetLoaderType: L.Type,
        record: DownloadRecord<S.Loader.Input, S.CustomData>,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        self.init(
            id: S.id(from: record.input),
            assetLoaderType: assetLoaderType,
            input: record.input,
            creationDate: record.creationDate,
            session: session,
            store: store
        )
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func fail(with error: Error) {
        errorSubject.send(error)
    }

    func remove() {
        removeFile()
        cancelOperations()
        removeRecord()
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
        properties.resume()
    }

    func suspend() {
        properties.suspend()
    }

    func restart() {
        remove()
        addRecord()
        trigger.activate(for: TriggerId.restart)
    }

    private func cancelOperations() {
        properties.cancel()
        trigger.activate(for: TriggerId.cancel)
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case restart
        case cancel
    }

    static func downloadProgressPublisher<L, S>(
        assetLoaderType: L.Type,
        storeType: S.Type,
        id: String,
        input: L.Input,
        session: DownloadSession,
        properties: DownloadProperties<S.CustomData>
    ) -> AnyPublisher<DownloadPhase<DownloadProgress, S.CustomData>, Error> where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        storeType.taskPublisher(id: id, input: input, reusableAssetMetadata: properties.reusableAssetMetadata, session: session)
            .map { task in
                if let sessionTask = task.result {
                    downloadSessionTaskPropertiesPublisher(for: sessionTask)
                        .map { DownloadPhase(result: DownloadProgress.actual($0), assetMetadata: task.assetMetadata) }
                        .eraseToAnyPublisher()
                }
                else {
                    Just(DownloadPhase(result: DownloadProgress.estimate(properties.fractionCompleted), assetMetadata: task.assetMetadata))
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    private static func downloadSessionTaskPropertiesPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTaskProperties, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map { task, state, progress in
            // If progress information is indeterminate (e.g. download happened too fast), still ensure that progress is
            // correct when completed.
            .init(task: task, state: state, progress: state == .completed ? 1 : progress)
        }
        .eraseToAnyPublisher()
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
                receiveOutput: { [id, creationDate] properties in
                    let record = DownloadRecord(
                        input: input,
                        metadata: properties.assetMetadata,
                        bookmarkData: properties.bookmarkData(),
                        progress: properties.fractionCompleted,
                        error: properties.error,
                        creationDate: creationDate
                    )
                    store.updateDownloadRecord(record, forId: id)
                },
                receiveCompletion: nil
            )
            .map { properties in
                DownloadProperties(
                    progress: properties.progress,
                    assetMetadata: properties.assetMetadata?.withoutCustomData(),
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
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.restart)) { [trigger, locationSubject, errorSubject] in
            let properties = store.downloadProperties(forId: id)
            return Publishers.CombineLatest3(
                Self.downloadProgressPublisher(
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
            .map { DownloadProperties(progress: $0.result, assetMetadata: $0.assetMetadata, fileUrl: $1, error: $2) }
            .fail(onOutputFrom: trigger.signal(activatedBy: TriggerId.cancel), with: URLError(.cancelled))
            .catch { Just(DownloadProperties(progress: .estimate(0), assetMetadata: nil, fileUrl: nil, error: $0)) }
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
