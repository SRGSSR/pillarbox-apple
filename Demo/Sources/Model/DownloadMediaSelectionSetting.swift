//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@_spi(DownloaderPrivate)
import PillarboxPlayer

@objc
enum DownloadMediaSelectionSetting: Int, CaseIterable {
    case automatic
    case swiss

    var name: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .swiss:
            return "🇨🇭 languages"
        }
    }

    var mediaSelectionPreference: DownloadMediaSelectionPreference {
        switch self {
        case .automatic:
            return .automatic
        case .swiss:
            return .languages("de", "fr", "it", "rm")
        }
    }
}
