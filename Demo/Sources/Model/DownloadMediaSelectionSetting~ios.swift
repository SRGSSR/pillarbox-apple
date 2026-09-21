//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

@objc
enum DownloadMediaSelectionSetting: Int, CaseIterable, CustomLocalizedStringResourceConvertible {
    case automatic
    case swiss
    case all

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .automatic:
            return "Automatic"
        case .swiss:
            return "Swiss languages"
        case .all:
            return "All"
        }
    }

    var mediaSelectionPreference: DownloadMediaSelectionPreference {
        switch self {
        case .automatic:
            return .automatic
        case .swiss:
            return .languages("de", "fr", "it", "rm")
        case .all:
            return .all
        }
    }
}
