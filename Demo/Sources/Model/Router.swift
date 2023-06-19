//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SwiftUI

enum Destination: Identifiable {
    case player(media: Media)

    var id: String {
        switch self {
        case let .player(media):
            return "player_\(media.id)"
        }
    }
}

final class Router: ObservableObject {
    @Published var path: [Destination] = []
    @Published var presented: Destination?
}

extension View {
    private static func presented(for router: Router) -> Binding<Destination?> {
        .init {
            router.presented
        } set: { newValue in
            router.presented = newValue
        }
    }

    func routed(by router: Router) -> some View {
        sheet(item: Self.presented(for: router)) { presented in
            switch presented {
            case let .player(media: media):
                PlayerView(media: media)
            }
        }
    }
}
