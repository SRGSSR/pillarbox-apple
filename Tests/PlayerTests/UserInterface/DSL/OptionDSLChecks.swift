//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum OptionDSLChecks {
    @InlinePickerContentBuilder<Bool>
    static func picker() -> InlinePickerContent<Bool> {
        Option("", value: true) { _ in }
        Option("", subtitle: "", value: true) { _ in }
        Option("", image: UIImage(), value: true) { _ in }
        Option("", subtitle: "", image: UIImage(), value: true) { _ in }
        Option("", image: .checkmark, value: true) { _ in }
        Option("", subtitle: "", image: .checkmark, value: true) { _ in }
        Option("", systemImage: "circle", value: true) { _ in }
        Option("", subtitle: "", systemImage: "circle", value: true) { _ in }
    }

    @PickerContentBuilder<Bool>
    static func picker() -> PickerContent<Bool> {
        Option("", value: true) { _ in }
        Option("", subtitle: "", value: true) { _ in }
        Option("", image: UIImage(), value: true) { _ in }
        Option("", subtitle: "", image: UIImage(), value: true) { _ in }
        Option("", image: .checkmark, value: true) { _ in }
        Option("", subtitle: "", image: .checkmark, value: true) { _ in }
        Option("", systemImage: "circle", value: true) { _ in }
        Option("", subtitle: "", systemImage: "circle", value: true) { _ in }
    }

    @PickerSectionContentBuilder<Bool>
    static func pickerSection() -> PickerSectionContent<Bool> {
        Option("", value: true) { _ in }
        Option("", subtitle: "", value: true) { _ in }
        Option("", image: UIImage(), value: true) { _ in }
        Option("", subtitle: "", image: UIImage(), value: true) { _ in }
        Option("", image: .checkmark, value: true) { _ in }
        Option("", subtitle: "", image: .checkmark, value: true) { _ in }
        Option("", systemImage: "circle", value: true) { _ in }
        Option("", subtitle: "", systemImage: "circle", value: true) { _ in }
    }
}
