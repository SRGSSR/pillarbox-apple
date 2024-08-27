//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum URNMedia {
    static let onDemandHorizontalVideo = Media(
        title: "Horizontal video",
        imageUrl: "https://www.rts.ch/2024/04/10/19/23/14827621.image/16x9",
        type: .urn("urn:rts:video:14827306")
    )
    static let onDemandSquareVideo = Media(
        title: "Square video",
        imageUrl: "https://www.rts.ch/2017/02/16/07/08/8393235.image/16x9",
        type: .urn("urn:rts:video:8393241")
    )
    static let onDemandVerticalVideo = Media(
        title: "Vertical video",
        imageUrl: "https://www.rts.ch/2022/10/06/17/32/13444380.image/4x5",
        type: .urn("urn:rts:video:13444390")
    )
    static let onDemandVideo = Media(
        title: "A bon entendeur",
        imageUrl: "https://www.rts.ch/2023/06/13/21/47/14071626.image/16x9",
        type: .urn("urn:rts:video:14080915")
    )
    static let liveVideo = Media(
        title: "SRF 1",
        subtitle: "Live video",
        imageUrl: "https://ws.srf.ch/asset/image/audio/d91bbe14-55dd-458c-bc88-963462972687/EPISODE_IMAGE",
        type: .urn("urn:srf:video:c4927fcf-e1a0-0001-7edd-1ef01d441651")
    )
    static let dvrVideo = Media(
        title: "RTS 1",
        subtitle: "DVR video livestream",
        imageUrl: "https://www.rts.ch/2023/09/06/14/43/14253742.image/16x9",
        type: .urn("urn:rts:video:3608506")
    )
    static let blockedTimeRangesVideo = Media(
        title: "Puls - Gehirnerschütterung, Akutgeriatrie, Erlenpollen im Winter",
        subtitle: "Content with a blocked time range",
        imageUrl: "https://ws.srf.ch/asset/image/audio/3bc7c819-9f77-4b2f-bbb1-6787df21d7bc/WEBVISUAL/1641807822.jpg",
        type: .urn("urn:srf:video:40ca0277-0e53-4312-83e2-4710354ff53e")
    )
    static let dvrAudio = Media(
        title: "Couleur 3 (DVR)",
        subtitle: "DVR audio livestream",
        imageUrl: "https://img.rts.ch/articles/2017/image/cxsqgp-25867841.image?w=640&h=640",
        type: .urn("urn:rts:audio:3262363")
    )
    static let gothard_360 = Media(
        title: "Gothard 360°",
        imageUrl: "https://www.rts.ch/2017/02/24/11/43/8414076.image/16x9",
        type: .urn("urn:rts:video:8414077")
    )
    static let expired = Media(
        title: "Expired URN",
        subtitle: "Content that is not available anymore",
        imageUrl: "https://www.rts.ch/2022/09/20/09/57/13365589.image/16x9",
        type: .urn("urn:rts:video:13382911")
    )
    static let unknown = Media(
        title: "Unknown URN",
        subtitle: "Content that does not exist",
        type: .urn("urn:srf:video:unknown")
    )
}
