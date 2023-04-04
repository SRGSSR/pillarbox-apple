//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

private var kIsInterceptorEnabled = false

enum ComScoreRequestInfoKey: String {
    case queryItems = "ComScoreRequestQueryItems"
}

extension Notification.Name {
    static let didReceiveComScoreRequest = Notification.Name("URLSessionDidReceiveComScoreRequestNotification")
}

extension URLSession {
    static func enableInterceptor() {
        guard !kIsInterceptorEnabled else { return }
        method_exchangeImplementations(
            class_getInstanceMethod(URLSession.self, NSSelectorFromString("dataTaskWithRequest:completionHandler:"))!,
            class_getInstanceMethod(URLSession.self, #selector(swizzled_dataTask(with:completionHandler:)))!
        )
        kIsInterceptorEnabled = true
    }

    @objc
    private func swizzled_dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        if let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let host = components.host, host.contains("scorecardresearch") {
            let queryItems = components.queryItems ?? []
            NotificationCenter.default.post(name: .didReceiveComScoreRequest, object: nil, userInfo: [
                ComScoreRequestInfoKey.queryItems: queryItems.reduce(into: [String: String]()) { partialResult, item in
                    guard let value = item.value?.removingPercentEncoding else { return }
                    partialResult[item.name] = value
                }
            ])
        }
        return swizzled_dataTask(with: request, completionHandler: completionHandler)
    }
}
