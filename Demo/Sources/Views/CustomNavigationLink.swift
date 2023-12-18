//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CustomNavigationLink<Content>: View where Content: View {
    let title: String
    let destination: RouterDestination
    @ViewBuilder let content: () -> Content

    var body: some View {
#if os(iOS)
        NavigationLink(title, destination: destination)
#else
        NavigationLink(destination: destination.view()) {
            content()
        }
        .buttonStyle(.card)
#endif
    }
}
