//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum UnbufferedURLMedia {
    static let liveAudio = Media(
        title: "Couleur 3 en direct",
        subtitle: "Audio livestream (unbuffered)",
        imageUrl: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=320&h=320",
        type: .unbufferedUrl("http://stream.srg-ssr.ch/m/couleur3/mp3_128")
    )
}
