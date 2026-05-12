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

    func metadata(for identifier: String) -> L.Metadata?
    func location(for identifier: String) -> URL?
    func updateDownloadRecord(_ record: DownloadRecord<L.Input, L.Metadata>, for identifier: String)
}

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download<L>: ObservableObject where L: AssetLoader {
    let id: String

    @Published private var properties: DownloadProperties<L.Metadata>

    private let trigger = Trigger()

    private let locationSubject = PassthroughSubject<URL, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()

    private weak let delegate: (any DownloadDelegate<L>)?

    public var progress: Double? {
        switch state {
        case .running, .suspended:
            return properties.taskProperties?.progress ?? 0
        default:
            return nil
        }
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
        else if properties.location != nil {
            return .completed
        }
        else {
            return .unknown
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

        configurePropertiesPublisher(input: record.input, session: session)
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

    private func configurePropertiesPublisher(input: L.Input, session: AVAssetDownloadURLSession) {
        propertiesPublisher(id: id, input: input, session: session)
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

    private func removeFile() {
        // TODO: Files are not properly removed in all cases
        if let location = properties.location {
            try? FileManager.default.removeItem(at: location)
        }
    }
}

@available(tvOS, unavailable)
private extension Download {
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

    static func taskPropertiesPublisher(id: String, input: L.Input, metadata: L.Metadata, createIfNeeded: Bool, session: AVAssetDownloadURLSession) -> AnyPublisher<TaskProperties?, Never> {
        session.taskPublisher(withDescription: id)
            .map { task in
                if let task {
                    return task
                }
                else if createIfNeeded {
                    return Self.task(id: id, input: input, metadata: metadata, using: session)
                }
                else {
                    return nil
                }
            }
            .map { taskPropertiesPublisher(task: $0) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    static func metadataPublisher(id: String, input: L.Input, delegate: (any DownloadDelegate<L>)?) -> AnyPublisher<L.Metadata, Error> {
        if let metadata = delegate?.metadata(for: id) {
            return Just(metadata)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        else {
            return L.metadataPublisher(for: input)
        }
    }

    func propertiesPublisher(id: String, input: L.Input, session: AVAssetDownloadURLSession) -> AnyPublisher<DownloadProperties<L.Metadata>, Never> {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [locationSubject, errorSubject, delegate] in
            Self.metadataPublisher(id: id, input: input, delegate: delegate)
                .map { metadata in
                    // TODO: Should likely avoid creating a task again if the user removed the file behind the bookmark
                    let location = delegate?.location(for: id)
                    return Publishers.CombineLatest4(
                        Just(metadata),
                        Self.taskPropertiesPublisher(id: id, input: input, metadata: metadata, createIfNeeded: location == nil, session: session),
                        locationSubject
                            .print("-->")
                            .map(\.self)
                            .prepend(location),
                        errorSubject
                            .map(\.self)
                            .prepend(nil)
                    )
                }
                .switchToLatest()
                .map { DownloadProperties(metadata: $0, taskProperties: $1, location: $2, error: $3) }
                .catch { error in
                    Just(DownloadProperties(metadata: nil, taskProperties: nil, location: nil, error: error))
                }
                .handleEvents(
                    receiveOutput: { properties in
                        let record = DownloadRecord(
                            input: input,
                            metadata: properties.metadata,
                            bookmarkData: try? properties.location?.bookmarkData(),
                            error: properties.error
                        )
                        // TODO: What should we do if delegate is nil?
                        delegate?.updateDownloadRecord(record, for: id)
                    },
                    receiveCompletion: nil)
                .eraseToAnyPublisher()
        }
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
