//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct CopyButton: View {
    let text: String

    var body: some View {
        Button {
            UIPasteboard.general.string = text
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .tint(.accentColor)
    }
}

#Preview {
    CopyButton(text: "Copy")
}
