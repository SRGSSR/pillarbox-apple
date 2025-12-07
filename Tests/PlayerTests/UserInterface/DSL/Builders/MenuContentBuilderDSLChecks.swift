//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum MenuContentBuilderDSLChecks {
    private static func TestButton() -> any MenuElement {
        Button("") {}
    }

    @MenuContentBuilder
    static func oneExpression() -> MenuContent {
        TestButton()
    }

    @MenuContentBuilder
    static func twoExpressions() -> MenuContent {
        TestButton()
        TestButton()
    }

    @MenuContentBuilder
    static func threeExpressions() -> MenuContent {
        TestButton()
        TestButton()
        TestButton()
    }

    @MenuContentBuilder
    static func forLoop() -> MenuContent {
        for _ in 0...2 {
            TestButton()
        }
    }

    @MenuContentBuilder
    static func ifStatement() -> MenuContent {
        if true {
            TestButton()
        }
    }

    @MenuContentBuilder
    static func ifElseStatements() -> MenuContent {
        if true {
            TestButton()
        }
        else {
            TestButton()
        }
    }

    @MenuContentBuilder
    static func switchStatement() -> MenuContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestButton()
        case 1:
            TestButton()
        default:
            TestButton()
        }
    }

    @MenuContentBuilder
    static func ifElseAvailableStatements() -> MenuContent {
        if #available(iOS 16, tvOS 16, *) {
            TestButton()
        }
        else {
            TestButton()
        }
    }
}
