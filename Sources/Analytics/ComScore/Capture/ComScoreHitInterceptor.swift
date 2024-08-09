//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

private var kInterceptorEnabled = false

private enum ComScoreRequestInfoKey: String {
    case queryItems = "ComScoreRequestQueryItems"
}

/// A tool that intercepts comScore requests and turns them into a hit stream.
enum ComScoreHitInterceptor {
    private static var started = false
    private static var cancellables = Set<AnyCancellable>()

    static func start(completion: @escaping () -> Void) {
        URLSession.enableInterceptor()
        guard !started else {
            completion()
            return
        }

        labelsPublisher()
            .filter { $0.ns_ap_ev == "start" }
            .sink { _ in
                started = true
                completion()
            }
            .store(in: &cancellables)
    }

    private static func labelsPublisher() -> AnyPublisher<ComScoreLabels, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { labels(from: $0) }
            .eraseToAnyPublisher()
    }

    static func publisher(for identifier: String) -> AnyPublisher<ComScoreHit, Never> {
        labelsPublisher()
            .filter { $0.listener_session_id == identifier }
            .compactMap { .init(from: $0) }
            .eraseToAnyPublisher()
    }

    private static func labels(from notification: Notification) -> ComScoreLabels? {
        guard let dictionary = notification.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] else {
            return nil
        }
        return .init(dictionary: dictionary)
    }
}

private extension Notification.Name {
    static let didReceiveComScoreRequest = Notification.Name("URLSessionDidReceiveComScoreRequestNotification")
}

private extension URLSession {
    static func enableInterceptor() {
        guard !kInterceptorEnabled else { return }
        method_exchangeImplementations(
            class_getInstanceMethod(URLSession.self, NSSelectorFromString("dataTaskWithRequest:completionHandler:"))!,
            class_getInstanceMethod(URLSession.self, #selector(swizzled_dataTask(with:completionHandler:)))!
        )
        kInterceptorEnabled = true
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
