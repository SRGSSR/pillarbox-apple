//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

private enum TestEnum: String, CaseIterable {
    case first
    case second
    case third
    case fourth
}

private enum OptionDSLChecks {
    @PickerContentBuilder<TestEnum>
    static func picker() -> PickerContent<TestEnum> {
        Option(title: "", value: .first) { _ in }
        Option(title: "", image: UIImage(), value: .second) { _ in }
        Option(title: "", image: .checkmark, value: .second) { _ in }
        Option(title: "", systemImage: "circle", value: .second) { _ in }
    }

    @PickerSectionContentBuilder<TestEnum>
    static func pickerSection() -> PickerSectionContent<TestEnum> {
        Option(title: "", value: .first) { _ in }
        Option(title: "", image: UIImage(), value: .second) { _ in }
        Option(title: "", image: .checkmark, value: .second) { _ in }
        Option(title: "", systemImage: "circle", value: .second) { _ in }
    }
}
