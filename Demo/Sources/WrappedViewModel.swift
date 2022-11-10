//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player

// MARK: View model

@MainActor
final class WrappedViewModel: ObservableObject {
    @Published var player = Player()
}
