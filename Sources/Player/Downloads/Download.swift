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
}

@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public final class Download<L>: ObservableObject where L: AssetLoader {
    let id: String

    private let trigger = Trigger()

    private let locationSubject = CurrentValueSubject<URL?, Never>(nil)
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)

    @Published private var properties: DownloadProperties<L.Metadata> = .init()

    private weak let delegate: (any DownloadDelegate<L.Metadata>)?

    public var progress: Double {
        properties.progress
    }

    public var state: DownloadState {
        .canceling
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

        propertiesPublisher(id: id, record: record, session: session)
            .receiveOnMainThread()
            .print("-->")
            .assign(to: &$properties)
    }

    private static func task(id: String, input: L.Input, metadata: L.Metadata, using session: AVAssetDownloadURLSession) -> URLSessionTask {
        let asset = L.asset(input: input, metadata: metadata)
        let configuration = AVAssetDownloadConfiguration(asset: .init(url: asset.resource.url()), title: L.playerMetadata(from: metadata).title ?? id)
        let task = session.makeAssetDownloadTask(downloadConfiguration: configuration)
        task.taskDescription = id
        task.resume()
        return task
    }

    public func metadata() -> PlayerMetadata {
        guard let metadata = properties.metadata else { return .empty }
        return L.playerMetadata(from: metadata)
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
    private static func taskPublisher(id: String, record: DownloadRecord<L.Input, L.Metadata>, metadata: L.Metadata, session: AVAssetDownloadURLSession) -> AnyPublisher<URLSessionTask?, Never> {
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

    private static func statePublisher(for task: URLSessionTask?) -> AnyPublisher<URLSessionTask.State, Never> {
        guard let task else {
            return Just(.suspended)
                .eraseToAnyPublisher()
        }
        return task.publisher(for: \.state)
            .eraseToAnyPublisher()
    }

    private static func progressPublisher(for task: URLSessionTask?) -> AnyPublisher<Double, Never> {
        guard let task else {
            return Just(0).eraseToAnyPublisher()
        }
        return task.progress.publisher(for: \.fractionCompleted)
            .map { $0.clamped(to: 0...1) }
            .eraseToAnyPublisher()
    }

    private static func locationPublisher(for download: Download?) -> AnyPublisher<URL?, Never> {
        guard let download else {
            return Just(nil).eraseToAnyPublisher()
        }
        return download.locationSubject
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
        metadataPublisher(for: record)
            .handleEvents(receiveOutput: { [weak self] metadata in
                self?.delegate?.didProvideMetadata(metadata, for: id)
            }, receiveCompletion: nil)
            .map { metadata in
                Publishers.CombineLatest(
                    Just(metadata),
                    Self.taskPublisher(id: id, record: record, metadata: metadata, session: session)
                )
            }
            .switchToLatest()
            .map { [weak self] metadata, task in
                Publishers.CombineLatest5(
                    Just(metadata),
                    Just(task),
                    Self.statePublisher(for: task),
                    Self.progressPublisher(for: task),
                    Self.locationPublisher(for: self)
                )
            }
            .switchToLatest()
            .map { metadata, task, state, progress, location in
                DownloadProperties(
                    metadata: metadata,
                    error: nil /* TODO */,
                    task: task,
                    state: state,
                    progress: progress,
                    bookmarkData: try? location?.bookmarkData()
                )
            }
            .catch { error in
                Just(DownloadProperties(metadata: nil, error: error, task: nil, state: .suspended, progress: 0, bookmarkData: nil))
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
