//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct LiveRadioToggle: Hashable {
    let title: String
    let audio: String
    let video: String

    func urn(for mode: LiveRadioToggleMode) -> String {
        switch mode {
        case .audio:
            return audio
        case .video:
            return video
        }
    }
}
