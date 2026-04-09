//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CopyActions: View {
    let text: String

    var body: some View {
        Button {
            UIPasteboard.general.string = text
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .tint(.accentColor)

        ShareLink(item: text) {
            Image(systemName: "square.and.arrow.up")
        }
    }
}

#Preview {
    List {
        Text("Swipe to reveal copy actions")
            .swipeActions {
                CopyActions(text: "Copy")
            }
    }
}
