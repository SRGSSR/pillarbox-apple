//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import UIKit

extension UIApplication {
    func applicationStatePublisher() -> AnyPublisher<ApplicationState, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: UIApplication.didEnterBackgroundNotification, object: self)
                .map { _ in .background },
            NotificationCenter.default.weakPublisher(for: UIApplication.didBecomeActiveNotification, object: self)
                .map { _ in .foreground }
        )
        .prepend(applicationState == .background ? .background : .foreground)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
