//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct LiveRadio: Hashable {
    let title: String
    let audio: String
    let video: String

    func urn(for mode: LiveRadioMode) -> String {
        switch mode {
        case .audio:
            return audio
        case .video:
            return video
        }
    }
}
