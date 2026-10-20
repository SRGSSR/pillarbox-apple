//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MalformedHLSError: Error {}

struct MoviePackage {
    private let packageUrls: [URL]

    init?(url: URL) {
        guard url.isFileURL, let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil) else { return nil }
        packageUrls = enumerator.allObjects
            .compactMap { object in
                guard let url = object as? URL else { return nil }
                return url.pathExtension == "m3u8" ? url : nil
            }
    }

    static func extractKeyUrls(from string: String) -> Set<URL> {
        let pattern = #/#EXT-X-(?:SESSION-)?KEY:(?=.*METHOD=AES-128).*URI="(?<url>https?[^"]+)"/#
        return Set(string.matches(of: pattern)
            .map(\.output.url)
            .compactMap { URL(string: String($0)) })
    }

    static func replaceUrl(_ url: URL, with data: Data, in string: String) -> String {
        string.replacingOccurrences(of: url.absoluteString, with: URI.dataUri(for: data))
    }

    static func inlineAES128Keys(in string: String) async -> String {
        var result = string
        for url in extractKeyUrls(from: string) {
            guard let (data, _) = try? await URLSession.shared.data(from: url) else { continue }
            result = replaceUrl(url, with: data, in: result)
        }
        return result
    }

    func inlineAES128Keys() async {
        for packageUrl in packageUrls {
            guard let content = try? String(contentsOf: packageUrl) else { continue }
            let newContent = await Self.inlineAES128Keys(in: content)
            try? newContent.write(to: packageUrl, atomically: true, encoding: .utf8)
        }
    }
}
