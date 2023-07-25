//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import YouTubeIdentifier

extension View {
    func youTubePaste(_ text: Binding<String>) -> some View {
        onAppear {
            guard let paste = UIPasteboard.general.string,
                  YouTubeIdentifier.extract(from: URL(string: paste)!) != nil else { return }
            text.wrappedValue = paste
        }
    }
}
