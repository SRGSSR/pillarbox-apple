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

final class SearchViewModel: ObservableObject, Refreshable {
    enum State: Equatable {
        case empty
        case loading
        case loaded(medias: [SRGMedia])
        case failed(Error)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty), (.loading, .loading):
                return true
            case let (.loaded(medias: lhsMedias), .loaded(medias: rhsMedias)):
                return lhsMedias == rhsMedias
            case let (.failed(lhsError), .failed(rhsError)):
                return lhsError as NSError == rhsError as NSError
            default:
                return false
            }
        }
    }

    enum TriggerId {
        case reload
        case loadMore
    }

    private static let settings = {
        let settings = SRGMediaSearchSettings()
        settings.aggregationsEnabled = false
        return settings
    }()

    @Published var text = ""
    @Published var state: State = .empty
    @Published var vendor: SRGVendor = .RTS

    private let trigger = Trigger()

    init() {
        Publishers.CombineLatest($text, $vendor)
            .debounceAfterFirst(for: 0.5, scheduler: DispatchQueue.main)
            .map { [trigger] text, vendor in
                Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
                    Self.mediasPublisher(text: text, vendor: vendor, trigger: trigger)
                }
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func mediasPublisher(text: String, vendor: SRGVendor, trigger: Trigger) -> AnyPublisher<State, Never> {
        guard !text.isEmpty else {
            return Just(.empty)
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
        .map { State.loaded(medias: $0.removeDuplicates()) }
        .catch { Just(State.failed($0)) }
        .prepend(.loading)
        .eraseToAnyPublisher()
    }

    func refresh() async {
        Task {
            try? await Task.sleep(for: .seconds(1))
            trigger.activate(for: TriggerId.reload)
        }
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }
}
