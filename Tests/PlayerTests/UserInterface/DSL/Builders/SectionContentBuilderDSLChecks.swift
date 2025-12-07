//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum SectionContentBuilderDSLChecks {
    private static func TestAction() -> any SectionElement {
        Button("") {}
    }

    @SectionContentBuilder
    static func oneExpression() -> SectionContent {
        TestAction()
    }

    @SectionContentBuilder
    static func twoExpressions() -> SectionContent {
        TestAction()
        TestAction()
    }

    @SectionContentBuilder
    static func threeExpressions() -> SectionContent {
        TestAction()
        TestAction()
        TestAction()
    }

    @SectionContentBuilder
    static func forLoop() -> SectionContent {
        for _ in 0...2 {
            TestAction()
        }
    }

    @SectionContentBuilder
    static func ifStatement() -> SectionContent {
        if true {
            TestAction()
        }
    }

    @SectionContentBuilder
    static func ifElseStatements() -> SectionContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @SectionContentBuilder
    static func switchStatement() -> SectionContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestAction()
        case 1:
            TestAction()
        default:
            TestAction()
        }
    }

    @SectionContentBuilder
    static func ifElseAvailableStatements() -> SectionContent {
        if #available(iOS 16, tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
