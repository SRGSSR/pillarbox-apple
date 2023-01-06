//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import OrderedCollections
import Player

// MARK: View model

final class StoriesViewModel: ObservableObject {
    private static let preloadDistance = 1
    private var players = OrderedDictionary<Story, Player?>()

    var stories: [Story] {
        Array(players.keys)
    }

    @Published var currentStory: Story {
        willSet {
            player(for: currentStory).pause()
            players = Self.players(for: stories, around: newValue, reusedFrom: players)
            player(for: newValue).play()
        }
    }

    init(stories: [Story]) {
        precondition(!stories.isEmpty)
        let currentStory = stories.first!
        self.currentStory = currentStory
        players = Self.players(for: stories, around: currentStory, reusedFrom: [:])
        player(for: currentStory).play()
    }

    private static func player(for story: Story) -> Player {
        Player(item: Media(from: story.template).playerItem())
    }

    private static func players(
        for stories: [Story],
        around currentStory: Story,
        reusedFrom players: OrderedDictionary<Story, Player?>
    ) -> OrderedDictionary<Story, Player?> {
        guard let currentIndex = stories.firstIndex(of: currentStory) else { return OrderedDictionary() }
        return stories.enumerated().reduce(into: OrderedDictionary<Story, Player?>()) { partialResult, item in
            let story = item.element
            if abs(item.offset - currentIndex) <= preloadDistance {
                if let player = players[story], let player {
                    partialResult.updateValue(player, forKey: story)
                }
                else {
                    partialResult.updateValue(player(for: story), forKey: story)
                }
            }
            else {
                partialResult.updateValue(nil, forKey: story)
            }
        }
    }

    func player(for story: Story) -> Player {
        if let player = players[story], let player {
            return player
        }
        else {
            return Player()
        }
    }
}
