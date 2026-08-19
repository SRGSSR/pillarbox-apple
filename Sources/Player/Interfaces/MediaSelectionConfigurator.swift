//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

protocol MediaSelectionConfigurator {
    func mediaSelections(from selection: AVMediaSelection, withLanguages languages: [String]) -> [AVMediaSelection]
}
