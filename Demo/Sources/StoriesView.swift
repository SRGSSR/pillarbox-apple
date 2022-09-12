//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI
import UserInterface

// MARK: View

struct StoriesView: View {
    @StateObject private var model = StoriesViewModel(stories: Story.stories)

    var body: some View {
        TabView(selection: $model.currentStory) {
            ForEach(model.stories) { story in
                VideoView(player: model.player(for: story), gravity: .resizeAspectFill)
                    .tag(story)
                    .ignoresSafeArea()
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
