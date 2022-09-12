//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Foundation
import Player

struct Story: Identifiable, Hashable {
    let id: Int
    let url: URL

    static let stories: [Story] = [
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13270535/d47afd3d-a0ba-3b59-a3ed-d806097b8a7e/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13228000/afda78a2-b04b-346c-b01c-00e6a617b993/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13227903/ee11ce1e-637c-3504-bf80-845143534b47/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13161499/6a317edc-283f-3118-a873-f45f4d54f13d/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13146443/aae1c63b-86ac-3353-84d3-490a36ead906/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103127/6082196f-749d-3d27-8833-0982ac076477/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103117/3a2790fe-4a17-3879-991a-55da1140b508/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103078/3165f1c9-e7b8-3662-9abe-42281ff3c2f6/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13048001/e7c5b992-feb6-3782-a512-912e97318a86/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13047962/dd34844b-c569-35e5-8d8b-7134e9d8884c/master.m3u8")!
    ].enumerated().map { Story(id: $0, url: $1) }
}

@MainActor
final class StoriesViewModel: ObservableObject {
    let stories: [Story]
    var players: [Story: Player]

    @Published var currentStory: Story

    private static func player(for story: Story) -> Player {
        let item = AVPlayerItem(url: story.url)
        return Player(item: item)
    }

    private static func players(for stories: [Story], reusedFrom players: [Story: Player]) -> [Story: Player] {
        stories.reduce([Story: Player]()) { partialResult, story in
            var updatedPlayers = partialResult
            updatedPlayers[story] = players[story] ?? player(for: story)
            return updatedPlayers
        }
    }

    init(stories: [Story]) {
        precondition(!stories.isEmpty)
        self.stories = stories
        currentStory = stories.first!
        players = Self.players(for: stories, reusedFrom: [:])
    }

    func player(for story: Story) -> Player {
        // TODO: If near current story (+1, 0, -1), check current players and return one playing the current content,
        //       if any. Otherwise instantiate with new item. Outside these 3 players return dummy Player()
        return players[story] ?? Player()
    }
}
