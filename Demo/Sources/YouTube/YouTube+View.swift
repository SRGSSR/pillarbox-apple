//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import YouTubeIdentifier

extension View {
    private static func paste(_ text: Binding<String>) {
        guard let paste = UIPasteboard.general.string,
              YouTubeIdentifier.extract(from: URL(string: paste)!) != nil else { return }
        text.wrappedValue = paste
    }

    func youTubePaste(_ text: Binding<String>) -> some View {
        onAppear {
            Self.paste(text)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Self.paste(text)
        }
    }
}
