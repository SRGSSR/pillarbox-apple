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

protocol DownloadDelegate<Metadata>: AnyObject {
    associatedtype Metadata

    func didProvideMetadata(_ metadata: Metadata, for identifier: String)
    func didProvideBookmarkData(_ bookmarkData: Data, for identifier: String)
    func didProvideError(_ error: any Error, for identifier: String)
}

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download<L>: ObservableObject where L: AssetLoader {
    let id: String

    private let trigger = Trigger()

    private let locationSubject = CurrentValueSubject<URL?, Never>(nil)
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)

    @Published private var properties: DownloadProperties<L.Metadata>

    private weak let delegate: (any DownloadDelegate<L.Metadata>)?

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
        delegate: any DownloadDelegate<L.Metadata>
    ) {
        self.id = id
        self.delegate = delegate
        self.properties = .init(from: record)
        configurePropertiesPublisher(record: record, session: session)
    }

    private static func task(id: String, input: L.Input, metadata: L.Metadata, using session: AVAssetDownloadURLSession) -> URLSessionTask {
        let asset = L.asset(input: input, metadata: metadata)
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: asset.resource.url()), title: L.playerMetadata(from: metadata).title ?? id)
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

    public func playerItem() -> PlayerItem? {
        // TODO:
        nil
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func complete(with error: Error?) {
        errorSubject.send(error)
    }

    func matches(task: URLSessionTask) -> Bool {
        task.taskDescription == id
    }

    public func playerItem(allowsPartial: Bool = true) -> PlayerItem? {
        .simple(url: URL(string: "")!)
    }
}

@available(tvOS, unavailable)
private extension Download {
    private static func taskPublisher(
        id: String,
        record: DownloadRecord<L.Input, L.Metadata>,
        metadata: L.Metadata,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<URLSessionTask?, Never> {
        session.taskPublisher(withDescription: id)
            .map { task in
                if let task {
                    return task
                }
                else if record.bookmarkData == nil {
                    return Self.task(id: id, input: record.input, metadata: metadata, using: session)
                }
                else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    private static func taskPropertiesPublisher(for task: URLSessionTask?) -> AnyPublisher<TaskProperties?, Never> {
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

    func metadataPublisher(for record: DownloadRecord<L.Input, L.Metadata>) -> AnyPublisher<L.Metadata, Error> {
        if let metadata = record.metadata {
            return Just(metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            return L.metadataPublisher(for: record.input)
                .handleEvents(receiveOutput: { [delegate, id] metadata in
                    delegate?.didProvideMetadata(metadata, for: id)
                }, receiveCompletion: nil)
                .map(\.self)
                .eraseToAnyPublisher()
        }
    }

    func propertiesPublisher(
        id: String,
        record: DownloadRecord<L.Input, L.Metadata>,
        session: AVAssetDownloadURLSession
    ) -> AnyPublisher<DownloadProperties<L.Metadata>, Never> {
        // TODO: Respond to trigger
        metadataPublisher(for: record)
            .handleEvents(receiveOutput: { [delegate] metadata in
                delegate?.didProvideMetadata(metadata, for: id)
            }, receiveCompletion: nil)
            .map { metadata in
                Publishers.CombineLatest(
                    Just(metadata),
                    Self.taskPublisher(id: id, record: record, metadata: metadata, session: session)
                )
            }
            .switchToLatest()
            .map { [delegate, locationSubject, errorSubject] metadata, task in
                Publishers.CombineLatest4(
                    Just(metadata),
                    Self.taskPropertiesPublisher(for: task),
                    locationSubject,
                    errorSubject
                        .handleEvents(receiveOutput: { error in
                            guard let error else { return }
                            delegate?.didProvideError(error, for: id)
                        }, receiveCompletion: nil)
                )
            }
            .switchToLatest()
            .map { [delegate] metadata, taskProperties, location, error in
                // TODO: Bookmark data creation should happen once
                let bookmarkData = try? location?.bookmarkData()
                if let bookmarkData {
                    delegate?.didProvideBookmarkData(bookmarkData, for: id)
                }
                return DownloadProperties(
                    metadata: metadata,
                    taskProperties: taskProperties,
                    bookmarkData: bookmarkData,
                    error: error
                )
            }
            .catch { error in
                Just(DownloadProperties(metadata: nil, taskProperties: nil, bookmarkData: nil, error: error))
            }
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
    }

    func suspend() {
    }

    func cancel() {
    }

    func restart() {
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
