//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

final class WrappedViewModel: ObservableObject {
    @Published var player = Player(configuration: .externalPlaybackDisabled)
}
