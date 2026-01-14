//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore
import SwiftUI

struct CountdownView: View {
    private static let formatter = DateComponentsFormatter()
    let endDate: Date
    @State private var interval: TimeInterval = 0


    var body: some View {
        Text(text())
            .foregroundStyle(.white)
            .monospaced()
            .font(.largeTitle)
            .bold()
            .padding()
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .contentTransition(.numericText())
            .animation(.easeIn, value: text())
//            .onReceive(Self.intervalPublisher(to: endDate), assign: \.self, to: $interval)
            .onReceive(Self.intervalPublisher(to: endDate)) { interval in
                self.interval = interval
            }
    }

    private static func intervalPublisher(to date: Date) -> AnyPublisher<TimeInterval, Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .map { date.timeIntervalSince($0) }
            .eraseToAnyPublisher()
    }

    private func text() -> String {
        Self.formatter.string(from: interval)!
    }
}

#Preview {
    CountdownView(endDate: Date(timeIntervalSinceNow: 100))
}
