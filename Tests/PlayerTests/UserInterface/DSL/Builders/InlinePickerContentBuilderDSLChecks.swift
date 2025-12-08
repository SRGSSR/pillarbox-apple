//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum InlinePickerContentBuilderDSLChecks {
    private static func TestOption() -> any InlinePickerElement<Bool> {
        Option("", value: true)
    }

    @InlinePickerContentBuilder<Bool>
    static func oneExpression() -> InlinePickerContent<Bool> {
        TestOption()
    }

    @InlinePickerContentBuilder<Bool>
    static func twoExpressions() -> InlinePickerContent<Bool> {
        TestOption()
        TestOption()
    }

    @InlinePickerContentBuilder<Bool>
    static func threeExpressions() -> InlinePickerContent<Bool> {
        TestOption()
        TestOption()
        TestOption()
    }

    @InlinePickerContentBuilder<Bool>
    static func forLoop() -> InlinePickerContent<Bool> {
        for _ in 0...2 {
            TestOption()
        }
    }

    @InlinePickerContentBuilder<Bool>
    static func ifStatement() -> InlinePickerContent<Bool> {
        if true {
            TestOption()
        }
    }

    @InlinePickerContentBuilder<Bool>
    static func ifElseStatements() -> InlinePickerContent<Bool> {
        if true {
            TestOption()
        }
        else {
            TestOption()
        }
    }

    @InlinePickerContentBuilder<Bool>
    static func switchStatement() -> InlinePickerContent<Bool> {
        switch Int.random(in: 0...2) {
        case 0:
            TestOption()
        case 1:
            TestOption()
        default:
            TestOption()
        }
    }

    @InlinePickerContentBuilder<Bool>
    static func ifElseAvailableStatements() -> InlinePickerContent<Bool> {
        if #available(iOS 16, tvOS 16, *) {
            TestOption()
        }
        else {
            TestOption()
        }
    }
}
