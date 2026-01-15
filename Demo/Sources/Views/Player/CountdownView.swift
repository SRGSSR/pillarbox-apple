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
    @Published var endDate = Date()
    var onEnded: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()

    init() {
        $endDate
            .map { Self.intervalPublisher(to: $0) }
            .switchToLatest()
            .assign(to: &$interval)

        $interval
            .map { $0?.rounded() }
            .filter { $0 == 0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.onEnded?()
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

    @StateObject private var model = CountdownViewModel()

    var body: some View {
        VStack {
            Text("Starts in")
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

    init(endDate: Date) {
        self.endDate = endDate
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
    CountdownView(endDate: Date().addingTimeInterval(10))
        .preferredColorScheme(.dark)
}
