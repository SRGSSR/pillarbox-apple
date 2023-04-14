//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Combine

public enum ComScoreRecorder {
    static let sessionIdentifierKey = "recorder_session_id"
    static private(set) var sessionIdentifier: String?
    
    /// Execute the provided closure in a test context identified with the provided identifier.
    public static func captureEvents(perform: (AnyPublisher<ComScoreEvent, Never>) -> Void) {
        assert(sessionIdentifier == nil, "Multiple captures are not supported")

        try? Analytics.shared.start(with: .init(vendor: .RTS, sourceKey: "source", site: "site"))

        let identifier = UUID().uuidString
        URLSession.toggleInterceptor()
        sessionIdentifier = identifier
        defer {
            URLSession.toggleInterceptor()
            sessionIdentifier = nil
        }

        let publisher = eventPublisher(for: identifier)
        perform(publisher)
    }

    private static func eventPublisher(for identifier: String) -> AnyPublisher<ComScoreEvent, Never> {
        NotificationCenter.default.publisher(for: .didReceiveComScoreRequest)
            .compactMap { $0.userInfo?[ComScoreRequestInfoKey.queryItems] as? [String: String] }
            .filter { $0[sessionIdentifierKey] == identifier }
            .compactMap { .init(from: $0) }
            .eraseToAnyPublisher()
    }
}

private enum ComScoreRequestInfoKey: String {
    case queryItems = "ComScoreRequestQueryItems"
}

private extension Notification.Name {
    static let didReceiveComScoreRequest = Notification.Name("URLSessionDidReceiveComScoreRequestNotification")
}

private extension URLSession {
    static func toggleInterceptor() {
        method_exchangeImplementations(
            class_getInstanceMethod(URLSession.self, NSSelectorFromString("dataTaskWithRequest:completionHandler:"))!,
            class_getInstanceMethod(URLSession.self, #selector(swizzled_dataTask(with:completionHandler:)))!
        )
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
