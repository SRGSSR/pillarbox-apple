//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import YouTubeIdentifier

extension View {
    private static func paste(_ text: Binding<String>) {
        guard UIPasteboard.general.hasYouTubeUrl,
              let paste = UIPasteboard.general.string else { return }
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

private extension UIPasteboard {
    var hasYouTubeUrl: Bool {
        guard let string else { return false }
        return YouTubeIdentifier.extract(from: URL(string: string)!) != nil
    }
}
