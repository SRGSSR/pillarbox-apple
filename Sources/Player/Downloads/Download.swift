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

    private let removeRecord: () -> Void

    public var progress: Double {
        properties.progress
    }

    public var state: DownloadState {
        properties.state
    }

    public var metadata: PlayerMetadata {
        properties.metadata?.playerMetadata ?? .empty
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
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        self.id = id
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
        let id = type(of: store).id(from: input)
        store.addDownloadRecord(.init(input: input), forId: id)
        self.init(id: id, assetLoaderType: assetLoaderType, input: input, session: session, store: store)
    }

    convenience init<L, S>(
        assetLoaderType: L.Type,
        record: DownloadRecord<S.Loader.Input, S.CustomData>,
        session: DownloadSession,
        store: S
    ) where L: AssetLoader, S: AssetDownloadStore, L == S.Loader {
        self.init(
            id: type(of: store).id(from: record.input),
            assetLoaderType: assetLoaderType,
            input: record.input,
            session: session,
            store: store
        )
    }

    func attach(to location: URL) {
        locationSubject.send(location)
    }

    func fail(with error: Error) {
        errorSubject.send(error)
        properties.cancel()
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

    func remove() {
        removeFile()
        cancelOperations()
        removeRecord()
    }

    func restart() {
        removeFile()
        cancelOperations()
        trigger.activate(for: TriggerId.reload)
    }

    private func cancelOperations() {
        properties.cancel()
        trigger.activate(for: TriggerId.cancel)
    }
}

@available(tvOS, unavailable)
private extension Download {
    enum TriggerId: Hashable {
        case reload
        case cancel
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
        // TODO:
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
