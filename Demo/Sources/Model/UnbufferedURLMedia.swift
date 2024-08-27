//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum UnbufferedURLMedia {
    static let liveVideo = Media(
        title: "Couleur 3 en direct",
        subtitle: "Live video (unbuffered)",
        imageUrl: "https://www.rts.ch/2020/05/18/14/20/11333286.image/16x9",
        type: .unbufferedUrl("https://rtsc3video.akamaized.net/hls/live/2042837/c3video/3/playlist.m3u8?dw=0")
    )
    static let liveAudio = Media(
        title: "Couleur 3 en direct",
        subtitle: "Audio livestream (unbuffered)",
        imageUrl: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=320&h=320",
        type: .unbufferedUrl("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
}
