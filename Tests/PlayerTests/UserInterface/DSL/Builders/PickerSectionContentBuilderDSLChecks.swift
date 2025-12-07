//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum PickerSectionContentBuilderDSLChecks {
    private static func TestOption() -> any PickerSectionElement<Bool> {
        Option("", value: true)
    }

    @PickerSectionContentBuilder<Bool>
    static func oneExpression() -> PickerSectionContent<Bool> {
        TestOption()
    }

    @PickerSectionContentBuilder<Bool>
    static func twoExpressions() -> PickerSectionContent<Bool> {
        TestOption()
        TestOption()
    }

    @PickerSectionContentBuilder<Bool>
    static func threeExpressions() -> PickerSectionContent<Bool> {
        TestOption()
        TestOption()
        TestOption()
    }

    @PickerSectionContentBuilder<Bool>
    static func forLoop() -> PickerSectionContent<Bool> {
        for _ in 0...2 {
            TestOption()
        }
    }

    @PickerSectionContentBuilder<Bool>
    static func ifStatement() -> PickerSectionContent<Bool> {
        if true {
            TestOption()
        }
    }

    @PickerSectionContentBuilder<Bool>
    static func ifElseStatements() -> PickerSectionContent<Bool> {
        if true {
            TestOption()
        }
        else {
            TestOption()
        }
    }

    @PickerSectionContentBuilder<Bool>
    static func switchStatement() -> PickerSectionContent<Bool> {
        switch Int.random(in: 0...2) {
        case 0:
            TestOption()
        case 1:
            TestOption()
        default:
            TestOption()
        }
    }

    @PickerSectionContentBuilder<Bool>
    static func ifElseAvailableStatements() -> PickerSectionContent<Bool> {
        if #available(iOS 16, tvOS 16, *) {
            TestOption()
        }
        else {
            TestOption()
        }
    }
}
