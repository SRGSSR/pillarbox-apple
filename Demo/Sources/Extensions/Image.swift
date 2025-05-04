//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

extension Image {
    init(systemName: String, placeholder: String) {
        if let uiImage = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate) {
            self = Image(uiImage: uiImage)
        }
        else {
            self = Image(systemName: placeholder)
        }
    }
}
