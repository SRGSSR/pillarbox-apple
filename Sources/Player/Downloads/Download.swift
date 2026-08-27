//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#if DEBUG

import Combine
import Foundation
import PillarboxCore

/// An observable object that represents a download.
///
/// A download is an [ObservableObject](https://developer.apple.com/documentation/combine/observableobject)
/// that publishes changes to its state.
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download: ObservableObject, Identifiable {
    private typealias DownloadPlayerProperties = DownloadProperties<Void>

    /// The download unique identifier.
    public let id: String

    @Published private var properties: DownloadPlayerProperties = .init()

    private let trigger = Trigger()
    private let session: any DownloadSession

    private let resetRecord: (DownloadConfiguration) -> Void
    private let removeRecord: () -> Void

    /// The date when the download was created.
    public let creationDate: Date

    /// The download's configuration.
    public var configuration: DownloadConfiguration {
        properties.configuration
    }

    /// Information about the download's progress.
    ///
    /// Returns a value between 0 and 1.
    public var progress: Double {
        properties.fractionCompleted
    }

    /// Information about the download's size.
    public var size: DownloadSize? {
        properties.size
    }

    /// The download state.
    public var state: DownloadState {
        properties.state
    }

    /// Standard playback metadata associated with the download.
    public var metadata: PlayerMetadata {
        properties.assetMetadata?.playerMetadata ?? .empty
    }

    /// Error information associated with the download, if any.
    public var error: Error? {
        properties.error
    }

    var fileUrl: URL? {
        properties.fileUrl
    }

    private init<S>(
        id: String,
        input: S.Loader.Input,
        configuration: DownloadConfiguration,
        creationDate: Date,
        session: DownloadSession,
        store: S
    ) where S: AssetDownloadStore {
        self.id = id
        self.creationDate = creationDate
        self.session = session
        self.resetRecord = { configuration in
            guard let record = store.downloadRecord(forId: id) else { return }
            store.updateDownloadRecord(record.reset(configuration: configuration), forId: id)
        }
        self.removeRecord = {
            store.removeDownloadRecord(forId: id)
        }
        configurePropertiesPublisher(input: input, store: store)
    }

    convenience init<S>(input: S.Loader.Input, configuration: DownloadConfiguration, session: DownloadSession, store: S) where S: AssetDownloadStore {
        let id = S.id(from: input)
        let creationDate = Date.now
        store.addDownloadRecord(.init(input: input, configuration: configuration, creationDate: creationDate), forId: id)
        self.init(id: id, input: input, configuration: configuration, creationDate: creationDate, session: session, store: store)
    }

    convenience init<S>(record: DownloadRecord<S.Loader.Input, S.CustomData>, session: DownloadSession, store: S) where S: AssetDownloadStore {
        self.init(
            id: S.id(from: record.input),
            input: record.input,
            configuration: record.configuration,
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
    /// Resumes the download.
    func resume() {
        properties.resume()
    }

    /// Suspends the download.
    func suspend() {
        properties.suspend()
    }

    /// Restarts the download.
    ///
    /// The original configuration is reused.
    func restart() {
        restart(configuration: configuration)
    }

    /// Restarts the download.
    ///
    /// - Parameter configuration: The configuration to use for the restarted download.
    ///
    /// The provided configuration replaces the original configuration.
    func restart(configuration: DownloadConfiguration) {
        removeFile()
        cancelOperations()
        resetRecord(configuration)
        trigger.activate(for: TriggerId.restart)
    }

    private func cancelOperations() {
        session.cancelTasks(matchingId: id)
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
            task.publisher(for: \.state),
            task.progress.publisher(for: \.completedUnitCount),
            task.progress.publisher(for: \.totalUnitCount)
        )
        .map { state, completed, total in
            DownloadSessionTaskProperties(
                task: task,
                state: state,
                size: .init(completed: completed, total: total)
            )
        }
        .eraseToAnyPublisher()
    }

    func propertiesPublisher<S>(input: S.Loader.Input, store: S) -> AnyPublisher<DownloadProperties<S.CustomData>, Never> where S: AssetDownloadStore {
        // swiftlint:disable:next closure_body_length
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.restart)) { [id, trigger, session] in
            let storedProperties = store.downloadProperties(forId: id)
            return S.taskPublisher(
                id: id,
                input: input,
                configuration: storedProperties.configuration,
                reusableAssetMetadata: storedProperties.reusableAssetMetadata,
                session: session
            )
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
                    .map { DownloadProperties(configuration: storedProperties.configuration, progress: .actual($0), assetMetadata: $1, fileUrl: $2, error: $3) }
                    .eraseToAnyPublisher()
                }
                else {
                    return task.assetMetadata.assetMetadataPublisher()
                        .map { assetMetadata in
                            DownloadProperties(
                                configuration: storedProperties.configuration,
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
            .catch { Just(store.downloadProperties(forId: id).withError($0)) }
            .prepend(storedProperties)
        }
    }

    func configurePropertiesPublisher<S>(input: S.Loader.Input, store: S) where S: AssetDownloadStore {
        propertiesPublisher(input: input, store: store)
            .receiveOnMainThread()
            .handleEvents(
                receiveOutput: { [id, creationDate] properties in
                    let record = DownloadRecord(
                        input: input,
                        configuration: properties.configuration,
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
                    configuration: properties.configuration,
                    progress: properties.progress,
                    assetMetadata: properties.assetMetadata?.withoutCustomData(),
                    fileUrl: properties.fileUrl,
                    error: properties.error
                )
            }
            .assign(to: &$properties)
    }
}

// TODO: Use the ID instead of reference equality when the feedback (https://github.com/SRGSSR/apple-bug-reports/blob/main/FB23923342/Report.md)
// is resolved by Apple.
@available(tvOS, unavailable)
extension Download: Hashable {
    // swiftlint:disable:next missing_docs
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs === rhs
    }

    // swiftlint:disable:next missing_docs
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

#endif
