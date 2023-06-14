//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SwiftUI

enum Signal {
    static func applicationWillEnterForeground() -> AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension View {
    func onForeground(perform action: @escaping () -> Void) -> some View {
        onReceive(Signal.applicationWillEnterForeground(), perform: action)
    }
}
