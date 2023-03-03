//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import SRGDataProvider
import SRGDataProviderCombine
import SRGDataProviderModel

final class SearchViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(medias: [SRGMedia])
        case failed(Error)
    }

    enum TriggerId {
        case reload
        case loadMore
    }

    private static var settings: SRGMediaSearchSettings = {
        let setting = SRGMediaSearchSettings()
        setting.aggregationsEnabled = false
        return setting
    }()

    private let trigger = Trigger()

    @Published var text = ""
    @Published var state: State = .loading
    @Published var vendor = SRGVendor.RTS

    init() {
        Publishers.CombineLatest($text, $vendor)
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { [trigger] text, vendor in
                Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
                    Self.mediasPublisher(text: text, vendor: vendor, trigger: trigger)
                        .map { State.loaded(medias: $0) }
                        .catch { Just(State.failed($0)) }
                        .prepend(.loading)
                }
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func mediasPublisher(text: String, vendor: SRGVendor, trigger: Trigger) -> AnyPublisher<[SRGMedia], Error> {
        guard !text.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return SRGDataProvider.current!.medias(
            for: vendor,
            matchingQuery: text,
            with: settings,
            pageSize: kPageSize,
            paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
        )
        .map { output in
            SRGDataProvider.current!.medias(withUrns: output.mediaUrns, pageSize: kPageSize)
        }
        .switchToLatest()
        .scan([], +)
        .eraseToAnyPublisher()
    }

    func refresh() async {
        Task {
            try await Task.sleep(for: .seconds(1))
            trigger.activate(for: TriggerId.reload)
        }
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }
}
