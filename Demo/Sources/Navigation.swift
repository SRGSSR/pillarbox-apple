//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct Navigation<Content: View>: View {
    let content: Content

    var body: some View {
#if os(iOS)
        NavigationStack {
            content
        }
#else
        content
#endif
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
}
