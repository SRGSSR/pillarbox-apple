//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView(frame: .zero)
        webView.load(.init(url: url))
        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

extension WebView: SourceCodeViewable {
    static var filePath: String { #file }
}
