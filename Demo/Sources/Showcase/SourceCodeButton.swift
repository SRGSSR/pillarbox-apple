//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

struct SourceCodeButton: View {
    let perform: () -> Void

    var body: some View {
        Button {
            perform()
        } label: {
            Image(systemName: "globe")
        }
        .tint(.secondary)
    }
}
