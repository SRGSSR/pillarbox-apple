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
    private static let urls = [
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13270535/d47afd3d-a0ba-3b59-a3ed-d806097b8a7e/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13228000/afda78a2-b04b-346c-b01c-00e6a617b993/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13227903/ee11ce1e-637c-3504-bf80-845143534b47/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13161499/6a317edc-283f-3118-a873-f45f4d54f13d/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13146443/aae1c63b-86ac-3353-84d3-490a36ead906/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103127/6082196f-749d-3d27-8833-0982ac076477/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103117/3a2790fe-4a17-3879-991a-55da1140b508/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13103078/3165f1c9-e7b8-3662-9abe-42281ff3c2f6/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13048001/e7c5b992-feb6-3782-a512-912e97318a86/master.m3u8")!,
        URL(string: "https://rts-vod-amd.akamaized.net/ww/13047962/dd34844b-c569-35e5-8d8b-7134e9d8884c/master.m3u8")!
    ]

    var body: some View {
        TabView {
            ForEach(Self.urls, id: \.self) { url in
                StoryView(url: url)
                    .ignoresSafeArea()
            }
        }
        .tabViewStyle(.page)
        .ignoresSafeArea()
    }
}

struct StoryView: View {
    let url: URL

    @StateObject private var player = Player()

    var body: some View {
        VideoView(player: player)
            .onAppear {
                play()
            }
            .onDisappear {
                stop()
            }
    }

    private func play() {
        player.append(AVPlayerItem(url: url))
        player.play()
    }

    private func stop() {
        player.removeAllItems()
    }
}

// MARK: Preview

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
