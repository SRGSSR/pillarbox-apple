//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension MediaComposition {
    struct Episode: Decodable {
        enum CodingKeys: String, CodingKey {
            case number
            case seasonNumber
        }

        let number: Int?
        let seasonNumber: Int?
    }
}
