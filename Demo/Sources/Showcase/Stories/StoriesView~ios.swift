//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct StoriesView: View {
    @StateObject private var model = StoriesViewModel(stories: Story.stories(from: MediaList.storyUrns))

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
