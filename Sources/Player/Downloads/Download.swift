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

    private let addRecord: () -> Void
    private let removeRecord: () -> Void
    private let cancelTasks: () -> Void

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
        properties.error
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
        self.cancelTasks = {
            session.cancelTasks(matchingId: id)
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
        cancelTasks()
        trigger.activate(for: TriggerId.cancel)
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case restart
        case cancel
    }
}

@available(tvOS, unavailable)
private extension Download {
    static func taskPropertiesPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTaskProperties, Never> {
        Publishers.CombineLatest3(
            Just(task),
            task.publisher(for: \.state),
            task.progress.publisher(for: \.fractionCompleted)
                .map { $0.clamped(to: 0...1) }
        )
        .map { task, state, progress in
            // If progress information is indeterminate (e.g. download happened too fast), still ensure that progress is
            // correct when completed.
            DownloadSessionTaskProperties(task: task, state: state, progress: state == .completed ? 1 : progress)
        }
        .eraseToAnyPublisher()
    }

    func propertiesPublisher<L, S>(
        assetLoaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) -> AnyPublisher<DownloadProperties<S.CustomData>, Never> where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        // swiftlint:disable:next closure_body_length
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.restart)) { [id, trigger] in
            let storedProperties = store.downloadProperties(forId: id)
            return S.taskPublisher(id: id, input: input, reusableAssetMetadata: storedProperties.reusableAssetMetadata, session: session)
                .map { task in
                    if let wrappedTask = task.wrappedValue {
                        return Publishers.CombineLatest4(
                            Self.taskPropertiesPublisher(for: wrappedTask),
                            task.assetMetadata.assetMetadataPublisher(),
                            wrappedTask.locationPublisher
                                .map(\.self)
                                .prepend(storedProperties.fileUrl),
                            wrappedTask.errorPublisher
                                .map(\.self)
                                .prepend(storedProperties.error)
                        )
                        .map { DownloadProperties(progress: .actual($0), assetMetadata: $1, fileUrl: $2, error: $3) }
                        .eraseToAnyPublisher()
                    }
                    else {
                        return task.assetMetadata.assetMetadataPublisher()
                            .map { assetMetadata in
                                DownloadProperties(
                                    progress: .estimate(storedProperties.fractionCompleted),
                                    assetMetadata: assetMetadata,
                                    fileUrl: storedProperties.fileUrl,
                                    error: storedProperties.error
                                )
                            }
                            .eraseToAnyPublisher()
                    }
                }
                .switchToLatest()
                .fail(onOutputFrom: trigger.signal(activatedBy: TriggerId.cancel), with: URLError(.cancelled))
                .catch { error in
                    Just(DownloadProperties(
                        progress: .estimate(0),
                        assetMetadata: storedProperties.assetMetadata,
                        fileUrl: storedProperties.fileUrl,
                        error: error
                    ))
                }
                .prepend(storedProperties)
        }
    }

    func configurePropertiesPublisher<L, S>(
        assetLoaderType: L.Type,
        input: L.Input,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        propertiesPublisher(assetLoaderType: assetLoaderType, input: input, session: session, store: store)
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
