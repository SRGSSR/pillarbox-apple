//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore
import PillarboxPlayer
import SwiftUI

private final class CountdownViewModel: ObservableObject {
    private static let formatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @Published private var interval: TimeInterval?
    @Published var endDate: Date?
    var onEnded: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $endDate
            .compactMap(\.self)
            .map { Self.intervalPublisher(to: $0) }
            .switchToLatest()
            .assign(to: &$interval)

        $interval
            .compactMap(\.self)
            .removeDuplicates()
            .filter { $0 == 0 }
            .sink { [weak self] _ in
                self?.onEnded?()
            }
            .store(in: &cancellables)

        Signal.applicationWillEnterForeground()
            .sink { [weak self] _ in
                guard let self, interval == 0 else { return }
                onEnded?()
            }
            .store(in: &cancellables)
    }

    private static func intervalPublisher(to date: Date) -> AnyPublisher<TimeInterval?, Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .map { max(date.timeIntervalSince($0), 0) }
            .eraseToAnyPublisher()
    }

    func text() -> String {
        Self.formatter.string(from: interval ?? 0)!
    }
}

struct CountdownView: View {
    let endDate: Date
    private var onEnded: (() -> Void)?

    let metadata: PlayerMetadata
    @StateObject private var model = CountdownViewModel()

    private var title: String {
        if let title = metadata.title {
            return "\(title) will start in"
        }
        else {
            return "Will start in"
        }
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.title3)
            Text(model.text())
                .foregroundStyle(.white)
                .monospaced()
                .font(.title)
                .bold()
                .contentTransition(.numericText())
                .animation(.default, value: model.text())
        }
        .onAppear {
            model.onEnded = onEnded
            model.endDate = endDate
        }
        .onChange(of: endDate) { endDate in
            model.endDate = endDate
        }
    }

    init(endDate: Date, metadata: PlayerMetadata) {
        self.endDate = endDate
        self.metadata = metadata
    }
}

extension CountdownView {
    func onEnded(_ action: @escaping () -> Void) -> Self {
        var view = self
        view.onEnded = action
        return view
    }
}

#Preview {
    CountdownView(endDate: Date().addingTimeInterval(10), metadata: .init(title: "19h30"))
        .preferredColorScheme(.dark)
}
