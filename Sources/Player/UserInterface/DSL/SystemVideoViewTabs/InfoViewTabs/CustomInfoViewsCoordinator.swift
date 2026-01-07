//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

final class CustomInfoViewsCoordinator {
    private var cache: [String: UIHostingController<AnyView>] = [:]

    func controller(using customInfoView: Tab<EmptyView>) -> UIViewController {
        // TODO: Will be removed
        return .init()
    }
}
