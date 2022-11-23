//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

// Behavior: h-exp, v-exp
struct StoriesView: View {
    @StateObject private var model = StoriesViewModel(stories: Story.stories(from: MediaURLPlaylist.videos))

    var body: some View {
        TabView(selection: $model.currentStory) {
            ForEach(model.stories) { story in
                StoryView(player: model.player(for: story))
                    .tag(story)
            }
        }
        .background(.black)
        .tabViewStyle(.page)
        .ignoresSafeArea()
    }
}

private extension StoriesView {
    // Behavior: h-exp, v-exp
    struct StoryView: View {
        @ObservedObject var player: Player
        @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

        var body: some View {
            ZStack {
                VideoView(player: player, gravity: .resizeAspectFill)
                    .ignoresSafeArea()
                if player.isBuffering {
                    // Ensure the animation is applied by setting its zIndex
                    // See https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
                    ProgressView()
                        .zIndex(1)
                }
                ProgressView(value: progressTracker.progress)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .tint(.white)
            .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
            .bind(progressTracker, to: player)
        }
    }
}

// MARK: Preview

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
