//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MoviePackage {
    private let location: URL
    private let package: HLSMoviePackage

    init?(location: URL) {
        guard location.isFileURL, let package = try? HLSMoviePackage(contentsOf: location.appending(component: "boot.xml")) else { return nil }
        self.location = location
        self.package = package
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

    static func inlineAES128Keys(in content: String, relativeTo streamUrl: URL) async -> String {
        var result = content
        for uri in extractKeyUris(from: content) {
            guard let url = URL(string: String(uri), relativeTo: streamUrl), let (data, _) = try? await URLSession.shared.data(from: url) else { continue }
            result = replaceUri(uri, with: data, in: result)
        }
        return result
    }

    private static func inlineAES128KeysInPlaylist(at url: URL, withStreamUrl streamUrl: URL) async {
        guard let content = try? String(contentsOf: url) else { return }
        let newContent = await inlineAES128Keys(in: content, relativeTo: streamUrl)
        try? newContent.write(to: url, atomically: true, encoding: .utf8)
    }

    func inlineAES128Keys() async {
        await inlineAES128KeysInPlaylists(inFolderNamed: "Data", withStreamUrl: package.masterPlaylistUrl)
        for stream in package.streams {
            await inlineAES128KeysInPlaylists(inFolderNamed: stream.path, withStreamUrl: stream.networkUrl)
        }
    }

    private func inlineAES128KeysInPlaylists(inFolderNamed folderName: String, withStreamUrl streamUrl: URL) async {
        for playlistUrl in playlistUrls(inFolderNamed: folderName) {
            await Self.inlineAES128KeysInPlaylist(at: playlistUrl, withStreamUrl: streamUrl)
        }
    }

    private func playlistUrls(inFolderNamed folderName: String) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(at: location.appending(component: folderName), includingPropertiesForKeys: nil) else { return [] }
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
