//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum MenuContentBuilderDSLChecks {
    private static func TestAction() -> any MenuElement {
        Action(title: "") {}
    }

    @MenuContentBuilder
    static func oneExpression() -> MenuContent {
        TestAction()
    }

    @MenuContentBuilder
    static func twoExpressions() -> MenuContent {
        TestAction()
        TestAction()
    }

    @MenuContentBuilder
    static func threeExpressions() -> MenuContent {
        TestAction()
        TestAction()
        TestAction()
    }

    @MenuContentBuilder
    static func forLoop() -> MenuContent {
        for _ in 0...2 {
            TestAction()
        }
    }

    @MenuContentBuilder
    static func ifStatement() -> MenuContent {
        if true {
            TestAction()
        }
    }

    @MenuContentBuilder
    static func ifElseStatements() -> MenuContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @MenuContentBuilder
    static func switchStatement() -> MenuContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestAction()
        case 1:
            TestAction()
        default:
            TestAction()
        }
    }

    @MenuContentBuilder
    static func ifElseAvailableStatements() -> MenuContent {
        if #available(iOS 16, tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
