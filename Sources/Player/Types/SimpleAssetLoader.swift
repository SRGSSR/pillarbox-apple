//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

enum SimpleAssetLoader: DownloadableAssetLoader {
    struct Input: Codable {
        enum CodingKeys: CodingKey {
            case url
            case title
        }

        let url: URL
        let metadata: PlayerMetadata
        let configuration: PlaybackConfiguration

        init(url: URL, metadata: PlayerMetadata, configuration: PlaybackConfiguration) {
            self.url = url
            self.metadata = metadata
            self.configuration = configuration
        }

        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.url = try container.decode(URL.self, forKey: .url)
            let title = try container.decode(String.self, forKey: .title)
            self.metadata = .init(title: title)
            self.configuration = .default
        }

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.url, forKey: .url)
            try container.encode(self.metadata.title, forKey: .title)
        }
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<PlayerMetadata>, Error> {
        Just(.simple(url: input.url, metadata: input.metadata, configuration: input.configuration))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension SimpleAssetLoader {
    private static let fileUrl = URL.libraryDirectory.appending(component: "_inputs.json")

    private static func inputs() -> [String: Input] {
        guard let data = try? Data(contentsOf: fileUrl),
              let inputs = try? JSONDecoder().decode([String: Input].self, from: data) else {
            return [:]
        }
        return inputs
    }

    static func identifier(from input: Input) -> String {
        input.url.absoluteString
    }

    static func setInput(_ input: Input, for identifier: String) {
        var inputs = inputs()
        inputs[identifier] = input
        guard let data = try? JSONEncoder().encode(inputs) else { return }
        try? data.write(to: fileUrl)
    }

    static func setMetadata(_ metadata: PlayerMetadata, for identifier: String) {}

    static func input(for identifier: String) -> Input? {
        inputs()[identifier]
    }

    static func metadata(for identifier: String) -> PlayerMetadata? {
        input(for: identifier)?.metadata
    }

    static func remove(for identifier: String) {
        var inputs = inputs()
        inputs.removeValue(forKey: identifier)
        guard let data = try? JSONEncoder().encode(inputs) else { return }
        try? data.write(to: fileUrl)
    }
}
