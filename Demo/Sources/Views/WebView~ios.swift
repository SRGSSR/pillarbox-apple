//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import WebKit

private struct _WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.load(.init(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct WebView: View {
    let url: URL

    var body: some View {
        NavigationStack {
            _WebView(url: url)
                .ignoresSafeArea()
                .navigationTitle("Web")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        CloseButton()
                    }
                }
        }
    }
}

extension WebView: SourceCodeViewable {
    static var filePath: String { #file }
}
