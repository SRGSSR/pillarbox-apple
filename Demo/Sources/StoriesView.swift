//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI

// Behavior: h-exp, v-exp
private struct StoryView: View {
    @ObservedObject var player: Player

    var body: some View {
        ZStack {
            VideoView(player: player, gravity: .resizeAspectFill)
                .ignoresSafeArea()
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
            TimeProgress(player: player)
        }
        .tint(.white)
        .animation(.easeInOut(duration: 0.2), value: player.isBusy)
    }
}

// Behavior: h-exp, v-exp
private struct TimeProgress: View {
    @ObservedObject var player: Player
    @StateObject private var progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 10))

    var body: some View {
        ProgressView(value: progressTracker.progress)
            .padding()
            .opacity(progressTracker.isProgressAvailable ? 1 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .bind(progressTracker, to: player)
    }
}

// Behavior: h-exp, v-exp
struct StoriesView: View {
    @StateObject private var model = StoriesViewModel(stories: Story.stories(from: URLTemplates.videos))

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

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
