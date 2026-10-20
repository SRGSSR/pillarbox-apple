//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MoviePackage {
    private let location: URL
    private let originalUrl: URL
    private let playlistUrls: [URL]

    init?(location: URL?, originalUrl: URL?) {
        guard let location,
              let originalUrl,
              location.isFileURL,
              let enumerator = FileManager.default.enumerator(at: location, includingPropertiesForKeys: nil) else {
            return nil
        }
        self.location = location
        self.originalUrl = originalUrl
        playlistUrls = enumerator.allObjects
            .compactMap { object in
                guard let url = object as? URL, url.pathExtension == "m3u8" else { return nil }
                return url
            }
    }

    static func extractKeyUris(from content: String) -> Set<String> {
        let pattern = #/#EXT-X-(?:SESSION-)?KEY:(?=.*METHOD=AES-128).*URI="(?<uri>(?!data:).+)"/#
        return Set(
            content.matches(of: pattern)
                .compactMap(\.output.uri)
                .map { String($0) }
        )
    }

    static func replaceUri(_ uri: String, with data: Data, in playlist: String) -> String {
        playlist.replacingOccurrences(of: "URI=\"\(uri)\"", with: "URI=\"\(URI.dataUri(for: data))\"")
    }

    static func inlineAES128Keys(in content: String, relativeTo originalUrl: URL) async -> String {
        var result = content
        for uri in extractKeyUris(from: content) {
            guard let url = URL(string: String(uri), relativeTo: originalUrl), let (data, _) = try? await URLSession.shared.data(from: url) else { continue }
            result = replaceUri(uri, with: data, in: result)
        }
        return result
    }

    func inlineAES128Keys() async {
        for playlistUrl in playlistUrls {
            guard let content = try? String(contentsOf: playlistUrl) else { continue }
            let newContent = await Self.inlineAES128Keys(in: content, relativeTo: originalUrl)
            try? newContent.write(to: playlistUrl, atomically: true, encoding: .utf8)
        }
    }

    func remove() async {
        do {
            try FileManager.default.removeItem(at: location)
        }
        catch {
            // The location is not always immediately removable when the task completes. Insert a second attempt after
            // a while if this failed the first time.
            try? await Task.sleep(for: .seconds(2))
            try? FileManager.default.removeItem(at: location)
        }
    }
}
