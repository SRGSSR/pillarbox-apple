//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import OrderedCollections
import PillarboxPlayer

final class StoriesViewModel: ObservableObject {
    private static let preloadDistance = 1
    private var players = OrderedDictionary<Story, Player?>()
    private var cancellables = Set<AnyCancellable>()

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
        configureAutomaticResume()
    }

    private static func player(for story: Story) -> Player {
        let player = Player(item: story.media.item(), configuration: .externalPlaybackDisabled)
        player.repeatMode = .one
        return player
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

    private func configureAutomaticResume() {
        Signal.applicationWillEnterForeground()
            .prepend(())
            .sink { [weak self] _ in
                guard let self else { return }
                player(for: currentStory).play()
            }
            .store(in: &cancellables)
    }
}
