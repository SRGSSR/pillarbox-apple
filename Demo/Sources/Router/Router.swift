//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxPlayer

/// A router managing application presentation.
///
/// You can manage navigation with a `RoutedNavigationStack` or use the router directly to present a single modal.
final class Router: ObservableObject {
    @Published var examplesPath: [RouterDestination] = []
    @Published var showcasePath: [RouterDestination] = []
    @Published var contentListsPath: [RouterDestination] = []
    @Published var searchPath: [RouterDestination] = []

#if DOWNLOADS
    @Published var downloadsPath: [RouterDestination] = []
#endif

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
        case .player, .systemPlayer, .playlist:
            previousPresented = presented
            presented = nil
#if os(iOS)
        case .multi, .twinsPiP, .multiPiP, .transitionPiP:
            previousPresented = presented
            presented = nil
        case .inlineSystemPlayer, .multiSystemPiP:
            previousPresented = presented
#endif
        default:
            break
        }
    }

    func pictureInPictureDidStart() {
        switch presented {
#if os(iOS)
        case .inlineSystemPlayer, .multiSystemPiP:
            presented = nil
#endif
        default:
            break
        }
    }

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

    func pictureInPictureWillStop() {}

    func pictureInPictureDidStop() {
        previousPresented = nil
    }
}
