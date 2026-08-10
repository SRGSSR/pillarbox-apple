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
public final class Download: ObservableObject, Identifiable {
    private typealias DownloadPlayerProperties = DownloadProperties<Void>

    public let id: String

    @Published private var properties: DownloadPlayerProperties = .init()

    private let trigger = Trigger()
    private let session: any DownloadSession

    private let resetRecord: () -> Void
    private let removeRecord: () -> Void

    public let creationDate: Date

    public var progress: Double {
        properties.fractionCompleted
    }

    public var size: DownloadSize? {
        properties.size
    }

    public var speed: Int? {
        properties.speed
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

    private init<S>(id: String, input: S.Loader.Input, creationDate: Date, session: DownloadSession, store: S) where S: AssetDownloadStore {
        self.id = id
        self.creationDate = creationDate
        self.session = session
        self.resetRecord = {
            guard let record = store.downloadRecord(forId: id) else { return }
            store.updateDownloadRecord(record.reset(), forId: id)
        }
        self.removeRecord = {
            store.removeDownloadRecord(forId: id)
        }
        configurePropertiesPublisher(input: input, store: store)
    }

    convenience init<S>(input: S.Loader.Input, session: DownloadSession, store: S) where S: AssetDownloadStore {
        let id = S.id(from: input)
        let creationDate = Date.now
        store.addDownloadRecord(.init(input: input, creationDate: creationDate), forId: id)
        self.init(id: id, input: input, creationDate: creationDate, session: session, store: store)
    }

    convenience init<S>(record: DownloadRecord<S.Loader.Input, S.CustomData>, session: DownloadSession, store: S) where S: AssetDownloadStore {
        self.init(id: S.id(from: record.input), input: record.input, creationDate: record.creationDate, session: session, store: store)
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
        removeFile()
        cancelOperations()
        resetRecord()
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

struct TaskCompletion {
    let unitCount: Int64
    let throughput: Int?
    let date = Date()

    init(unitCount: Int64, throughput: Int?) {
        self.unitCount = unitCount
        self.throughput = throughput
    }

    init(progress: Progress) {
        self.unitCount = progress.completedUnitCount
        self.throughput = nil
    }

    func throughput(toUnitCount unitCount: Int64) -> Int? {
        Int(Double(unitCount - self.unitCount) / Date().timeIntervalSince(date))
    }
}

@available(tvOS, unavailable)
private extension Download {
    private static func taskCompletion(for task: URLSessionTask) -> AnyPublisher<TaskCompletion, Never> {
        task.progress.publisher(for: \.completedUnitCount)
            .scan(.init(progress: task.progress)) { completion, unitCount in
                TaskCompletion(
                    unitCount: unitCount,
                    throughput: completion.throughput(toUnitCount: unitCount)
                )
            }
            .eraseToAnyPublisher()
    }

    static func taskPropertiesPublisher(for task: URLSessionTask) -> AnyPublisher<DownloadSessionTaskProperties, Never> {
        Publishers.CombineLatest3(
            task.publisher(for: \.state),
            Self.taskCompletion(for: task),
            task.progress.publisher(for: \.totalUnitCount)
        )
        .map { state, completion, totalUnitCount in
            DownloadSessionTaskProperties(
                task: task,
                state: state,
                size: .init(completed: completion.unitCount, total: totalUnitCount),
                speed: completion.throughput
            )
        }
        .eraseToAnyPublisher()
    }

    func propertiesPublisher<S>(input: S.Loader.Input, store: S) -> AnyPublisher<DownloadProperties<S.CustomData>, Never> where S: AssetDownloadStore {
        // swiftlint:disable:next closure_body_length
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.restart)) { [id, trigger, session] in
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

// TODO: Use the ID instead of reference equality when the feedback (https://github.com/SRGSSR/apple-bug-reports/blob/main/FB23923342/Report.md)
// is resolved by Apple.
@available(tvOS, unavailable)
extension Download: Hashable {
    public static func == (lhs: Download, rhs: Download) -> Bool {
        lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

#endif

// swiftlint:enable missing_docs
