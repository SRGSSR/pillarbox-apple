//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player
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

/// Manages application routes.
///
/// You can manage navigation with a `RoutedNavigationStack` or retrieve the router through the environment
/// to present the associated modal.
final class Router: ObservableObject {
    @Published var examplesPath: [RouterDestination] = []
    @Published var showcasePath: [RouterDestination] = []
    @Published var contentListsPath: [RouterDestination] = []
    @Published var searchPath: [RouterDestination] = []
    @Published var settingsPath: [RouterDestination] = []

    @Published var presented: RouterDestination? {
        didSet {
            guard presented != nil else { return }
            previousPresented = nil
        }
    }

    private var previousPresented: RouterDestination?

    init() {
        PictureInPicture.setDelegate(self)
    }
}

extension Router: PictureInPictureDelegate {
    func pictureInPictureWillStart(_ pictureInPicture: PictureInPicture) {
        switch presented {
        case .player:
            previousPresented = presented
            presented = nil
        default:
            break
        }
    }

    func pictureInPictureDidStart(_ pictureInPicture: PictureInPicture) {}

    func pictureInPictureController(_ pictureInPicture: PictureInPicture, failedToStartWithError error: Error) {}

    func pictureInPicture(
        _ pictureInPicture: PictureInPicture,
        restoreUserInterfaceForStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        if let previousPresented, previousPresented != presented {
            presented = previousPresented
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                completionHandler(true)
            }
        }
        else {
            completionHandler(true)
        }
    }

    func pictureInPictureWillStop(_ pictureInPicture: PictureInPicture) {}

    func pictureInPictureDidStop(_ pictureInPicture: PictureInPicture) {}
}
