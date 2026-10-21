//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

private final class ParserDelegate: NSObject, XMLParserDelegate {
    private var path: [String] = []
    private var text = ""

    var streams: [HLSMoviePackage.Stream] = []

    // swiftlint:disable:next inclusive_language
    var masterPlaylistUrl: URL?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        path.append(elementName)
        text = ""

        switch path {
        case ["HLSMoviePackage", "Streams", "Stream"]:
            guard let path = attributeDict["Path"], let networkUrl = attributeDict["NetworkURL"].flatMap(URL.init) else { break }
            streams.append(.init(path: path, networkUrl: networkUrl))
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch path {
        case ["HLSMoviePackage", "MasterPlaylist", "NetworkURL"]:
            masterPlaylistUrl = URL(string: text)
        default:
            break
        }
        path.removeLast()
    }
}

struct HLSMoviePackage: Equatable {
    struct Stream: Equatable {
        let path: String
        let networkUrl: URL
    }

    let streams: [Stream]

    // swiftlint:disable:next inclusive_language
    let masterPlaylistUrl: URL
}

extension HLSMoviePackage {
    enum ParsingError: Error {
        case invalidFormat
    }

    init(contentsOf url: URL) throws {
        try self.init(data: Data(contentsOf: url))
    }

    init(data: Data) throws {
        let delegate = ParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse(), let url = delegate.masterPlaylistUrl else {
            throw ParsingError.invalidFormat
        }
        self.init(streams: delegate.streams, masterPlaylistUrl: url)
    }
}
