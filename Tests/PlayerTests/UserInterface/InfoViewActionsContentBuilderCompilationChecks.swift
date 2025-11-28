//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum InfoViewActionsContentBuilderCompilationChecks {
    private static func TestAction() -> InfoViewAction {
        Action(title: "") {}
    }

    @InfoViewActionsContentBuilder
    static func oneExpression() -> InfoViewActionsContent {
        TestAction()
    }

    @InfoViewActionsContentBuilder
    static func twoExpressions() -> InfoViewActionsContent {
        TestAction()
        TestAction()
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfOnly() -> InfoViewActionsContent {
        if true {
            TestAction()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithNestedIf() -> InfoViewActionsContent {
        if true {
            if true {
                TestAction()
            }
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfElse() -> InfoViewActionsContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithSwitch() -> InfoViewActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestAction()
        case 1:
            TestAction()
        default:
            TestAction()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfAvailable() -> InfoViewActionsContent {
        if #available(tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
