//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum TestEnum: String, CaseIterable {
    case first
    case second
    case third
}

private enum PickerSectionContentBuilderDSLChecks {
    private static func TestOption(value: TestEnum) -> any PickerSectionElement<TestEnum> {
        Option(value.rawValue, value: value)
    }

    @PickerSectionContentBuilder<TestEnum>
    static func oneExpression() -> PickerSectionContent<TestEnum> {
        TestOption(value: .first)
    }

    @PickerSectionContentBuilder<TestEnum>
    static func twoExpressions() -> PickerSectionContent<TestEnum> {
        TestOption(value: .first)
        TestOption(value: .second)
    }

    @PickerSectionContentBuilder<TestEnum>
    static func threeExpressions() -> PickerSectionContent<TestEnum> {
        TestOption(value: .first)
        TestOption(value: .second)
        TestOption(value: .third)
    }

    @PickerSectionContentBuilder<TestEnum>
    static func forLoop() -> PickerSectionContent<TestEnum> {
        for value in TestEnum.allCases {
            TestOption(value: value)
        }
    }

    @PickerSectionContentBuilder<TestEnum>
    static func ifStatement() -> PickerSectionContent<TestEnum> {
        if true {
            TestOption(value: .first)
        }
    }

    @PickerSectionContentBuilder<TestEnum>
    static func ifElseStatements() -> PickerSectionContent<TestEnum> {
        if true {
            TestOption(value: .first)
        }
        else {
            TestOption(value: .second)
        }
    }

    @PickerSectionContentBuilder<TestEnum>
    static func switchStatement() -> PickerSectionContent<TestEnum> {
        switch Int.random(in: 0...2) {
        case 0:
            TestOption(value: .first)
        case 1:
            TestOption(value: .second)
        default:
            TestOption(value: .third)
        }
    }

    @PickerSectionContentBuilder<TestEnum>
    static func ifElseAvailableStatements() -> PickerSectionContent<TestEnum> {
        if #available(iOS 16, tvOS 16, *) {
            TestOption(value: .first)
        }
        else {
            TestOption(value: .second)
        }
    }
}
