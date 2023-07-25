//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import YouTubeIdentifier

extension View {
#if os(iOS)
    private static func paste(_ text: Binding<String>) {
        guard UIPasteboard.general.hasYouTubeUrl,
              let paste = UIPasteboard.general.string else { return }
        text.wrappedValue = paste
    }
#endif

    func youTubePaste(_ text: Binding<String>) -> some View {
#if os(iOS)
        onAppear {
            Self.paste(text)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Self.paste(text)
        }
#else
        self
#endif
    }
}

#if os(iOS)
private extension UIPasteboard {
    var hasYouTubeUrl: Bool {
        guard let string else { return false }
        return YouTubeIdentifier.extract(from: URL(string: string)!) != nil
    }
}
#endif
