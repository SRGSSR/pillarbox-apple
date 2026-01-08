//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

@available(iOS, introduced: 16.0, deprecated: 16.4, message: "Use `safeAreaRegions` instead")
@available(tvOS, introduced: 16.0, deprecated: 16.4, message: "Use `safeAreaRegions` instead")
extension UIHostingController {
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)

        if ignoreSafeArea {
            disableSafeArea()
        }
    }

    func disableSafeArea() {
        guard let viewClass = object_getClass(view) else { return }
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")

        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(view, viewSubclass)
        }
        else {
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewSubclassName, 0) else {
                return
            }

            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in .zero }
                class_addMethod(
                    viewSubclass,
                    #selector(getter: UIView.safeAreaInsets),
                    imp_implementationWithBlock(safeAreaInsets),
                    method_getTypeEncoding(method)
                )
            }

            objc_registerClassPair(viewSubclass)
            object_setClass(view, viewSubclass)
        }
    }
}
