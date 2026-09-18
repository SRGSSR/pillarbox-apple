//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// FIXME: Remove this view when Apple fixes `NavigationLinkPickerStyle` on tvOS 27.
struct PickerLabel: View {
    let title: String
    let value: String

    var body: some View {
        if #available(tvOS 27, *) {
            HStack(spacing: 0) {
                Text(value)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        else {
            Text(value)
        }
    }
}
