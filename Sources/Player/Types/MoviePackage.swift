//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MoviePackage {
    private let location: URL
    private let manifest: MoviePackageManifest

    init?(location: URL) {
        guard location.isFileURL, let manifest = try? MoviePackageManifest(contentsOf: location.appending(component: "boot.xml")) else { return nil }
        self.location = location
        self.manifest = manifest
    }

    static func extractKeyUris(from playlist: String) -> Set<String> {
        let pattern = #/#EXT-X-(?:SESSION-)?KEY:(?=.*METHOD=AES-128).*URI="(?<uri>(?!data:).+)"/#
        return Set(
            playlist.matches(of: pattern)
                .compactMap(\.output.uri)
                .map { String($0) }
        )
    }

    static func replaceUri(_ uri: String, with data: Data, in playlist: String) -> String {
        playlist.replacingOccurrences(of: "URI=\"\(uri)\"", with: "URI=\"\(URI.dataUri(for: data))\"")
    }

    static func inlineAES128Keys(in playlist: String, relativeTo streamUrl: URL) async -> String {
        var result = playlist
        for uri in extractKeyUris(from: playlist) {
            guard let url = URL(string: String(uri), relativeTo: streamUrl), let (data, _) = try? await URLSession.shared.data(from: url) else { continue }
            result = replaceUri(uri, with: data, in: result)
        }
        return result
    }

    private static func inlineAES128KeysInPlaylist(at url: URL, relativeTo streamUrl: URL) async {
        guard let content = try? String(contentsOf: url) else { return }
        let newContent = await inlineAES128Keys(in: content, relativeTo: streamUrl)
        try? newContent.write(to: url, atomically: true, encoding: .utf8)
    }

    func inlineAES128Keys() async {
        await inlineAES128KeysInPlaylists(atPath: "Data", relativeTo: manifest.masterPlaylistUrl)
        for stream in manifest.streams {
            await inlineAES128KeysInPlaylists(atPath: stream.path, relativeTo: stream.networkUrl)
        }
    }

    private func inlineAES128KeysInPlaylists(atPath path: String, relativeTo streamUrl: URL) async {
        for playlistUrl in playlistUrls(atPath: path) {
            await Self.inlineAES128KeysInPlaylist(at: playlistUrl, relativeTo: streamUrl)
        }
    }

    private func playlistUrls(atPath path: String) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: location.appending(component: path), includingPropertiesForKeys: nil) else { return [] }
        return enumerator.allObjects
            .compactMap { object in
                guard let url = object as? URL, url.pathExtension == "m3u8" else { return nil }
                return url
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
