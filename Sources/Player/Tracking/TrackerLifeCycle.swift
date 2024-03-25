//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

protocol TrackerLifeCycle {
    func enable(for player: Player)
    func updateProperties(_ properties: PlayerProperties)
    func disable()
}
