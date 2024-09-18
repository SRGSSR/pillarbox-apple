//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer
import SwiftUI

/// Manages navigation using an associated router.
struct RoutedNavigationStack<Root>: View where Root: View {
    let keyPath: ReferenceWritableKeyPath<Router, [RouterDestination]>

    @ViewBuilder let root: () -> Root
    @EnvironmentObject private var router: Router

    var body: some View {
        NavigationStack(path: Binding(router, at: keyPath)) {
            root()
                .navigationDestination(for: RouterDestination.self) { destination in
                    destination.view()
                }
        }
    }
}

/// A router managing application presentation.
///
/// You can manage navigation with a `RoutedNavigationStack` or use the router directly to present a single modal.
final class Router: ObservableObject {
    @Published var examplesPath: [RouterDestination] = []
    @Published var showcasePath: [RouterDestination] = []
    @Published var contentListsPath: [RouterDestination] = []
    @Published var searchPath: [RouterDestination] = []
    @Published var settingsPath: [RouterDestination] = []

    @Published var presented: RouterDestination?

    private var previousPresented: RouterDestination?

    init() {
        PictureInPicture.shared.delegate = self
    }
}

extension Router: PictureInPictureDelegate {
    func pictureInPictureWillStart() {
        switch presented {
        case .player, .systemPlayer, .playlist, .multi, .twinsAdvancedPiP, .transitionAdvancedPiP:
            previousPresented = presented
            presented = nil
        case .inlineSystemPlayer:
            previousPresented = presented
        default:
            break
        }
    }

    func pictureInPictureDidStart() {}

    func pictureInPictureControllerFailedToStart(with error: Error) {}

    func pictureInPictureRestoreUserInterfaceForStop(with completion: @escaping (Bool) -> Void) {
        if let previousPresented, previousPresented != presented {
            presented = previousPresented
            completion(true)
        }
        else {
            completion(true)
        }
    }

    func pictureInPictureWillStop() {
        previousPresented = nil
    }

    func pictureInPictureDidStop() {}
}
