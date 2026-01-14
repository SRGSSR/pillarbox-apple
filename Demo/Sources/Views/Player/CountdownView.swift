//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore
import SwiftUI

private final class CountdownModel: ObservableObject {
    private static let formatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    @Published private var interval: TimeInterval = 0
    @Published var endDate = Date()

    init() {
        $endDate
            .map { Self.intervalPublisher(to: $0) }
            .switchToLatest()
            .assign(to: &$interval)
    }

    private static func intervalPublisher(to date: Date) -> AnyPublisher<TimeInterval, Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .map { max(date.timeIntervalSince($0), 0) }
            .eraseToAnyPublisher()
    }

    func text() -> String {
        Self.formatter.string(from: interval)!
    }
}

struct CountdownView: View {
    let endDate: Date
    @StateObject private var model = CountdownModel()

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
                .onAppear {
                    model.endDate = endDate
                }
                .onChange(of: endDate) { endDate in
                    model.endDate = endDate
                }
        }
    }
}
#Preview {
    CountdownView(endDate: Date().addingTimeInterval(3600))
        .preferredColorScheme(.dark)
}
