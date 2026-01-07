//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

final class CustomInfoViewsCoordinator {
    private var cache: [String: UIHostingController<AnyView>] = [:]

    func controller(using customInfoView: CustomInfoView) -> UIViewController {
        if let controller = cache[customInfoView.title] {
            controller.rootView = customInfoView.view
            return controller
        }
        let controller = UIHostingController(rootView: customInfoView.view)
        cache[customInfoView.title] = controller
        return controller
    }
}
