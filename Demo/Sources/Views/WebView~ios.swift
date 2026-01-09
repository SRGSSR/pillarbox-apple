//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SafariServices
import SwiftUI

struct WebView: View {
    let url: URL

    var body: some View {
        SafariWebView(url: url)
            .ignoresSafeArea()
    }
}

private struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        .init(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

extension WebView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    WebView(url: URL(string: "https://www.pillarbox.ch")!)
}
