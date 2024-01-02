//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import WebKit

private struct _WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView(frame: .zero)
        webView.load(.init(url: url))
        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct WebView: View {
    let url: URL

    var body: some View {
        ZStack(alignment: .topLeading) {
            _WebView(url: url)
            CloseButton()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

extension WebView: SourceCodeViewable {
    static var filePath: String { #file }
}
