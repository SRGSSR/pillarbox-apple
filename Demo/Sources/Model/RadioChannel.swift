//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel

enum RadioChannel: String {
    case SRF1 = "69e8ac16-4327-4af4-b873-fd5cd6e895a7"
    case SRF2Kultur = "c8537421-c9c5-4461-9c9c-c15816458b46"
    case SRF3 = "dd0fa1ba-4ff6-4e1a-ab74-d7e49057d96f"
    case SRF4News = "ee1fb348-2b6a-4958-9aac-ec6c87e190da"
    case SRFMusikwelle = "a9c5c070-8899-46c7-ac27-f04f1be902fd"
    case SRFVirus = "66815fe2-9008-4853-80a5-f9caaffdf3a9"
    case RTSLaPremiere = "a9e7621504c6959e35c3ecbe7f6bed0446cdf8da"
    case RTSEspace2 = "a83f29dee7a5d0d3f9fccdb9c92161b1afb512db"
    case RTSCouleur3 = "8ceb28d9b3f1dd876d1df1780f908578cbefc3d7"
    case RTSOptionMusique = "f8517e5319a515e013551eea15aa114fa5cfbc3a"
    case RTSPodcastsOriginaux = "123456789101112131415161718192021222324x"
    case RSIReteUno = "rete-uno"
    case RSIReteDue = "rete-due"
    case RSIReteTre = "rete-tre"
    case RTR = "12fb886e-b7aa-4e55-beb2-45dbc619f3c4"

    var name: String {
        switch self {
        case .SRF1:
            return "SRF 1"
        case .SRF2Kultur:
            return "SRF 2 Kultur"
        case .SRF3:
            return "SRF 3"
        case .SRF4News:
            return "SRF 4 News"
        case .SRFMusikwelle:
            return "SRF Musikwelle"
        case .SRFVirus:
            return "SRF Virus"
        case .RTSLaPremiere:
            return "RTS La 1ère"
        case .RTSEspace2:
            return "RTS Espace 2"
        case .RTSCouleur3:
            return "RTS Couleur 3"
        case .RTSOptionMusique:
            return "RTS Option Musique"
        case .RTSPodcastsOriginaux:
            return "RTS Podcasts Originaux"
        case .RSIReteUno:
            return "RSI Rete Uno"
        case .RSIReteDue:
            return "RSI Rete Due"
        case .RSIReteTre:
            return "RSI Rete Tre"
        case .RTR:
            return "RTR"
        }
    }
}
