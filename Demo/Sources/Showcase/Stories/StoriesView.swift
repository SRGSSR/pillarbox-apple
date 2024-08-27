//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

// Behavior: h-exp, v-exp
private struct StoryView: View {
    @ObservedObject var player: Player
    @State private var isBusy = false

    var body: some View {
        ZStack {
            VideoView(player: player)
                .gravity(.resizeAspectFill)
                .ignoresSafeArea()
            ProgressView()
                .opacity(isBusy ? 1 : 0)
            TimeProgress(player: player)
        }
        .tint(.white)
        .animation(.defaultLinear, value: isBusy)
        .onReceive(player: player, assign: \.isBusy, to: $isBusy)
    }
}

// Behavior: h-exp, v-exp
private struct TimeProgress: View {
    let player: Player
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
    @StateObject private var model = StoriesViewModel(stories: Story.stories(from: MediaList.videoUrls))

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
        .tracked(name: "stories")
    }
}

extension StoriesView: SourceCodeViewable {
    static let filePath = #file
}

#Preview {
    StoriesView()
}
