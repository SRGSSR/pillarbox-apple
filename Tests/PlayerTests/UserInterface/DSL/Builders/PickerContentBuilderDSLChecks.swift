//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum PickerContentBuilderDSLChecks {
    private static func TestOption() -> any PickerElement<Bool> {
        Option("", value: true)
    }

    @PickerContentBuilder<Bool>
    static func oneExpression() -> PickerContent<Bool> {
        TestOption()
    }

    @PickerContentBuilder<Bool>
    static func twoExpressions() -> PickerContent<Bool> {
        TestOption()
        TestOption()
    }

    @PickerContentBuilder<Bool>
    static func threeExpressions() -> PickerContent<Bool> {
        TestOption()
        TestOption()
        TestOption()
    }

    @PickerContentBuilder<Bool>
    static func forLoop() -> PickerContent<Bool> {
        for _ in 0...2 {
            TestOption()
        }
    }

    @PickerContentBuilder<Bool>
    static func ifStatement() -> PickerContent<Bool> {
        if true {
            TestOption()
        }
    }

    @PickerContentBuilder<Bool>
    static func ifElseStatements() -> PickerContent<Bool> {
        if true {
            TestOption()
        }
        else {
            TestOption()
        }
    }

    @PickerContentBuilder<Bool>
    static func switchStatement() -> PickerContent<Bool> {
        switch Int.random(in: 0...2) {
        case 0:
            TestOption()
        case 1:
            TestOption()
        default:
            TestOption()
        }
    }

    @PickerContentBuilder<Bool>
    static func ifElseAvailableStatements() -> PickerContent<Bool> {
        if #available(iOS 16, tvOS 16, *) {
            TestOption()
        }
        else {
            TestOption()
        }
    }
}
