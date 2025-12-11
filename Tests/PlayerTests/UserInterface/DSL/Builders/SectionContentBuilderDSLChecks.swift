//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum SectionContentBuilderDSLChecks {
    private static func TestButton() -> any SectionElement {
        Button("") {}
    }

    @SectionContentBuilder
    static func oneExpression() -> SectionContent {
        TestButton()
    }

    @SectionContentBuilder
    static func twoExpressions() -> SectionContent {
        TestButton()
        TestButton()
    }

    @SectionContentBuilder
    static func threeExpressions() -> SectionContent {
        TestButton()
        TestButton()
        TestButton()
    }

    @SectionContentBuilder
    static func forLoop() -> SectionContent {
        for _ in 0...2 {
            TestButton()
        }
    }

    @SectionContentBuilder
    static func ifStatement() -> SectionContent {
        if true {
            TestButton()
        }
    }

    @SectionContentBuilder
    static func ifElseStatements() -> SectionContent {
        if true {
            TestButton()
        }
        else {
            TestButton()
        }
    }

    @SectionContentBuilder
    static func switchStatement() -> SectionContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestButton()
        case 1:
            TestButton()
        default:
            TestButton()
        }
    }

    @SectionContentBuilder
    static func ifElseAvailableStatements() -> SectionContent {
        if #available(iOS 16, tvOS 16, *) {
            TestButton()
        }
        else {
            TestButton()
        }
    }
}
