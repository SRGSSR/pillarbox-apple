//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderModel
import SwiftUI

final class Router: ObservableObject {
    @Published var path: [Destination] = []
    @Published var presented: Destination?
}
