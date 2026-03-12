//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DownloadedFile: Codable, Equatable {
    case unassigned
    case assigned(Data)
}
