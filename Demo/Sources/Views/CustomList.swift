//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CustomList<Content>: View where Content: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
#if os(iOS)
        List(content: content)
#else
        ScrollView {
            VStack(alignment: .leading, content: content)
        }
#endif
    }
}
