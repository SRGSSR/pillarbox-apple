//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

enum LiveRadioToggleMode: String, Identifiable, CaseIterable {
    case audio = "Audio"
    case video = "Video"

    var id: Self { self }

    var medias: [Media] {
        switch self {
        case .audio:
            [
                .init(title: "SRF1", type: .urn("urn:srf:audio:69e8ac16-4327-4af4-b873-fd5cd6e895a7")),
                .init(title: "SRF3", type: .urn("urn:srf:audio:dd0fa1ba-4ff6-4e1a-ab74-d7e49057d96f")),
                .init(title: "SRF Musikwelle", type: .urn("urn:srf:audio:a9c5c070-8899-46c7-ac27-f04f1be902fd")),
                .init(title: "SRF Virus", type: .urn("urn:srf:audio:66815fe2-9008-4853-80a5-f9caaffdf3a9")),
                .init(title: "RTS Couleur3", type: .urn("urn:rts:audio:3262363"))
            ]
        case .video:
            [
                .init(title: "SRF1", type: .urn("urn:srf:video:5b90d1fb-477b-4d98-86a6-82921a4bb0ea")),
                .init(title: "SRF3", type: .urn("urn:srf:video:972b2dbd-3958-43b7-8c15-e92f56c8d734")),
                .init(title: "SRF Musikwelle", type: .urn("urn:srf:video:973440d3-60a5-4ddf-ae83-2c77815a32a1")),
                .init(title: "SRF Virus", type: .urn("urn:srf:video:2a60b590-8a28-4540-bce8-fc4e52b3b5d8")),
                .init(title: "RTS Couleur3", type: .urn("urn:rts:video:8841634"))
            ]
        }
    }
}
