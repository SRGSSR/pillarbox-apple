//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI
import UIKit

extension UIView {
    /// Sizing behaviors
    enum SizingBehavior {
        /// The view matches the size of its content.
        case hugging
        /// The view takes as much space as offered.
        case expanding
    }

    /// Probe some hosting controller to determine the behavior of its SwiftUI view in some direction.
    private func sizingBehavior<T>(of hostingController: UIHostingController<T>, for axis: NSLayoutConstraint.Axis) -> SizingBehavior {
        // Fit into the maximal allowed layout size to check which boundaries are adopted by the associated view
        let size = hostingController.sizeThatFits(in: UIView.layoutFittingExpandedSize)
        if axis == .vertical {
            return size.height == UIView.layoutFittingExpandedSize.height ? .expanding : .hugging
        }
        else {
            return size.width == UIView.layoutFittingExpandedSize.width ? .expanding : .hugging
        }
    }

    /// Apply the specified sizing behavior in some direction.
    func applySizingBehavior(_ sizingBehavior: SizingBehavior, for axis: NSLayoutConstraint.Axis) {
        switch sizingBehavior {
        case .hugging:
            setContentHuggingPriority(.required, for: axis)
            setContentCompressionResistancePriority(.required, for: axis)
        case .expanding:
            setContentHuggingPriority(UILayoutPriority(0), for: axis)
            setContentCompressionResistancePriority(UILayoutPriority(0), for: axis)
        }
    }

    /// Apply the specified sizing behavior in all directions.
    func applySizingBehavior(_ sizingBehavior: SizingBehavior) {
        applySizingBehavior(sizingBehavior, for: .horizontal)
        applySizingBehavior(sizingBehavior, for: .vertical)
    }

    /// Apply the same sizing behavior as the provided hosting controller in some directions (layout neutrality).
    func applySizingBehavior<T>(of hostingController: UIHostingController<T>, for axis: NSLayoutConstraint.Axis) {
        applySizingBehavior(sizingBehavior(of: hostingController, for: axis), for: axis)
    }

    /// Apply the same sizing behavior as the provided hosting controller in all directions (layout neutrality).
    func applySizingBehavior<T>(of hostingController: UIHostingController<T>) {
        applySizingBehavior(of: hostingController, for: .horizontal)
        applySizingBehavior(of: hostingController, for: .vertical)
    }
}
