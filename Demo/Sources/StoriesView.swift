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

private struct StoryView: View {
    @ObservedObject var player: Player

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
            if let value = player.progress.value {
                ProgressView(value: value)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .tint(.white)
        .animation(.easeInOut(duration: 0.2), value: player.isBuffering)
    }
}

struct StoriesView: View {
    @StateObject private var model = StoriesViewModel(stories: Story.stories)

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

// MARK: Preview

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
