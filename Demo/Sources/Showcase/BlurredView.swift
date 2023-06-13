//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Combine
import Player
import SwiftUI

// Behavior: h-exp, v-exp
struct BlurredView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .externalPlaybackDisabled)

    var body: some View {
        ZStack {
            VideoView(player: player, gravity: .resizeAspectFill)
                .blur(radius: 20)
            VideoView(player: player)
                .ignoresSafeArea()
            ProgressView()
                .opacity(player.isBusy ? 1 : 0)
        }
        .background(.black)
        .onAppear(perform: play)
        .onReceive(applicationWillEnterForegroundPublisher()) { _ in
            player.play()
        }
        .tracked(title: "blurred")
    }

    private func play() {
        player.append(media.playerItem())
        player.play()
    }

    private func applicationWillEnterForegroundPublisher() -> AnyPublisher<Void, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

struct BlurredView_Previews: PreviewProvider {
    static var previews: some View {
        BlurredView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
    }
}
