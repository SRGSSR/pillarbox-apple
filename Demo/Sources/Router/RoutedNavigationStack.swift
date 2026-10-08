//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// Manages navigation using an associated router.
struct RoutedNavigationStack<Root>: View where Root: View {
    let keyPath: ReferenceWritableKeyPath<Router, [RouterDestination]>

    @ContentBuilder let root: () -> Root
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
