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

struct StoryView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            VideoView(player: player, gravity: .resizeAspectFill)
                .ignoresSafeArea()
            ProgressView(value: player.progress.value)
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: Preview

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
