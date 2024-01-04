//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import PillarboxPlayer
import SwiftUI

struct OptInView: View {
    let media: Media

    @StateObject private var player = Player(configuration: .standard)

    @State private var isActive = true
    @State private var supportsPictureInPicture = true
    @State private var audiovisualBackgroundPlaybackPolicy: AVPlayerAudiovisualBackgroundPlaybackPolicy = .automatic

    var body: some View {
        VStack {
            PlaybackView(player: player)
                .supportsPictureInPicture(supportsPictureInPicture)
                .background(.black)
            List {
                Toggle(isOn: $isActive) {
                    Text("Active")
                }
                Toggle(isOn: $supportsPictureInPicture) {
                    Text("Picture in Picture")
                }
                audiovisualBackgroundPlaybackPolicyPicker()

                Section {
                    Toggle(isOn: $player.isTrackingEnabled) {
                        Text("Tracking")
                    }
                } footer: {
                    Text("Use a proxy tool to observe events.")
                }
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                player.becomeActive()
            }
            else {
                player.resignActive()
            }
        }
        .onChange(of: audiovisualBackgroundPlaybackPolicy) { newValue in
            player.audiovisualBackgroundPlaybackPolicy = newValue
        }
        .onAppear(perform: play)
        .tracked(name: "tracking")
    }

    @ViewBuilder
    private func audiovisualBackgroundPlaybackPolicyPicker() -> some View {
        Picker("Audiovisual background policy", selection: $audiovisualBackgroundPlaybackPolicy) {
            Text("Automatic").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.automatic)
            Text("Continues if possible").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.continuesIfPossible)
            Text("Pauses").tag(AVPlayerAudiovisualBackgroundPlaybackPolicy.pauses)
        }
    }

    private func play() {
        player.append(media.playerItem())
        player.becomeActive()
        player.play()
    }
}

extension OptInView: SourceCodeViewable {
    static var filePath: String { #file }
}

#Preview {
    OptInView(media: Media(from: URLTemplate.onDemandVideoLocalHLS))
}
