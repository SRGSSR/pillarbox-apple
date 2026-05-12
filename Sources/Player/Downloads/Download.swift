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

protocol DownloadDelegate<L>: AnyObject {
    associatedtype L: AssetLoader

    func shouldUpdateRecord(_ record: DownloadRecord<L.Input, L.Metadata>, for identifier: String)
}

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download<L>: ObservableObject where L: AssetLoader {
    let id: String

    @Published private var properties: DownloadProperties<L.Metadata>

    private let trigger = Trigger()

    private let locationSubject: CurrentValueSubject<URL?, Never>
    private let errorSubject: CurrentValueSubject<Error?, Never>

    private weak let delegate: (any DownloadDelegate<L>)?

    public var isProgressAvailable: Bool {
        properties.taskProperties != nil
    }

    public var progress: Double {
        properties.taskProperties?.progress ?? 0
    }

    public var state: DownloadState {
        if let error = properties.error {
            return .failed(error)
        }
        else if let taskProperties = properties.taskProperties {
            switch taskProperties.state {
            case .running, .canceling:
                return .running
            case .suspended:
                return .suspended
            case .completed:
                return .completed
            @unknown default:
                assertionFailure("Unhandled case")
                return .completed
            }
        }
        else {
            return .completed
        }
    }

    init(
        id: String,
        loaderType: L.Type,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession,
        delegate: any DownloadDelegate<L>
    ) {
        self.id = id
        self.delegate = delegate

        self.properties = .init(from: record)
        self.locationSubject = .init(Self.url(fromBookmarkData: record.bookmarkData))
        self.errorSubject = .init(record.error)

        configurePropertiesPublisher(record: record, session: session)
    }

    private static func url(fromBookmarkData bookmarkData: Data?) -> URL? {
        guard let bookmarkData else { return nil }
        var isStale = false
        return try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
    }

    private static func task(id: String, input: L.Input, metadata: L.Metadata, using session: AVAssetDownloadURLSession) -> URLSessionTask {
        let asset = L.asset(input: input, metadata: metadata)
        let configuration = AVAssetDownloadConfiguration(
            asset: .init(url: asset.resource.url()),
            title: L.playerMetadata(from: metadata).title ?? id
        )
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    private func configurePropertiesPublisher(record: DownloadRecord<L.Input, L.Metadata>, session: AVAssetDownloadURLSession) {
        propertiesPublisher(id: id, record: record, session: session)
            .receiveOnMainThread()
            .assign(to: &$properties)
    }

    public func metadata() -> PlayerMetadata {
        guard let metadata = properties.metadata else { return .empty }
        return L.playerMetadata(from: metadata)
    }

    public func playerItem(allowsPartial: Bool = true) -> PlayerItem? {
        // TODO:
        nil
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

    private func fileUrl() -> URL? {
        Self.url(fromBookmarkData: properties.bookmarkData)
    }

    private func removeFile() {
        if let url = fileUrl() {
            try? FileManager.default.removeItem(at: url)
        }
        if let url = locationSubject.value {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

@available(tvOS, unavailable)
private extension Download {
    static func metadataPublisher(record: DownloadRecord<L.Input, L.Metadata>) -> AnyPublisher<L.Metadata, Error> {
        if let metadata = record.metadata {
            return Just(metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            return L.metadataPublisher(for: record.input)
                .eraseToAnyPublisher()
        }
    }

    static func taskPropertiesPublisher(
        id: String,
        record: DownloadRecord<L.Input, L.Metadata>,
        metadata: L.Metadata,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<TaskProperties?, Never> {
        session.taskPublisher(withDescription: id)
            .map { task in
                if let task {
                    return task
                }
                else if record.bookmarkData != nil {
                    return nil
                }
                else {
                    return Self.task(id: id, input: record.input, metadata: metadata, using: session)
                }
            }
            .map { taskPropertiesPublisher(task: $0) }
            .switchToLatest()
            .eraseToAnyPublisher()
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

    func propertiesPublisher(
        id: String,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<DownloadProperties<L.Metadata>, Never> {
        Self.metadataPublisher(record: record)
            .map { [locationSubject, errorSubject] metadata in
                Publishers.CombineLatest4(
                    Just(metadata),
                    Self.taskPropertiesPublisher(id: id, record: record, metadata: metadata, session: session),
                    locationSubject,
                    errorSubject
                )
            }
            .switchToLatest()
            .map { metadata, taskProperties, location, error in
                DownloadProperties(
                    metadata: metadata,
                    taskProperties: taskProperties,
                    bookmarkData: try? location?.bookmarkData(),
                    error: error
                )
            }
            .catch { error in
                Just(DownloadProperties(metadata: nil, taskProperties: nil, bookmarkData: nil, error: error))
            }
            .handleEvents(receiveOutput: { [delegate] properties in
                let record = DownloadRecord(input: record.input, metadata: properties.metadata, bookmarkData: properties.bookmarkData, error: properties.error)
                delegate?.shouldUpdateRecord(record, for: id)
            }, receiveCompletion: nil)
            .eraseToAnyPublisher()
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case reload
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
        properties.taskProperties?.task.cancel()
        removeFile()
    }

    func restart() {
        removeFile()
        trigger.activate(for: TriggerId.reload)
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
