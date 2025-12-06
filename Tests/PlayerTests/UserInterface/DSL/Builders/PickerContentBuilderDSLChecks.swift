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

private enum PickerContentBuilderDSLChecks {
    private static func TestOption(value: TestEnum) -> any PickerElement<TestEnum> {
        Option(title: value.rawValue, value: value)
    }

    @PickerContentBuilder<TestEnum>
    static func oneExpression() -> PickerContent<TestEnum> {
        TestOption(value: .first)
    }

    @PickerContentBuilder<TestEnum>
    static func twoExpressions() -> PickerContent<TestEnum> {
        TestOption(value: .first)
        TestOption(value: .second)
    }

    @PickerContentBuilder<TestEnum>
    static func threeExpressions() -> PickerContent<TestEnum> {
        TestOption(value: .first)
        TestOption(value: .second)
        TestOption(value: .third)
    }

    @PickerContentBuilder<TestEnum>
    static func forLoop() -> PickerContent<TestEnum> {
        for value in TestEnum.allCases {
            TestOption(value: value)
        }
    }

    @PickerContentBuilder<TestEnum>
    static func ifStatement() -> PickerContent<TestEnum> {
        if true {
            TestOption(value: .first)
        }
    }

    @PickerContentBuilder<TestEnum>
    static func ifElseStatements() -> PickerContent<TestEnum> {
        if true {
            TestOption(value: .first)
        }
        else {
            TestOption(value: .second)
        }
    }

    @PickerContentBuilder<TestEnum>
    static func switchStatement() -> PickerContent<TestEnum> {
        switch Int.random(in: 0...2) {
        case 0:
            TestOption(value: .first)
        case 1:
            TestOption(value: .second)
        default:
            TestOption(value: .third)
        }
    }

    @PickerContentBuilder<TestEnum>
    static func ifElseAvailableStatements() -> PickerContent<TestEnum> {
        if #available(iOS 16, tvOS 16, *) {
            TestOption(value: .first)
        }
        else {
            TestOption(value: .second)
        }
    }
}
