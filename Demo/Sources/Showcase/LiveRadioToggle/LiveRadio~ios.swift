//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct LiveRadio: Hashable {
    let title: String
    let audioUrn: String
    let videoUrn: String

    func urn(for mode: LiveRadioMode) -> String {
        switch mode {
        case .audio:
            return audioUrn
        case .video:
            return videoUrn
        }
    }
}
