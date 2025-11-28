//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum ContextualActionsContentBuilderCompilationChecks {
    private static func TestAction() -> ContextualAction {
        Action(title: "") {}
    }

    @ContextualActionsContentBuilder
    static func oneExpression() -> ContextualActionsContent {
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func twoExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func threeExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func fourExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func fiveExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func sixExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func sevenExpressions() -> ContextualActionsContent {
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
        TestAction()
    }

    @ContextualActionsContentBuilder
    static func expressionWithIfOnly() -> ContextualActionsContent {
        if true {
            TestAction()
        }
    }

    @ContextualActionsContentBuilder
    static func expressionWithNestedIf() -> ContextualActionsContent {
        if true {
            if true {
                TestAction()
            }
        }
    }

    @ContextualActionsContentBuilder
    static func expressionWithIfElse() -> ContextualActionsContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @ContextualActionsContentBuilder
    static func expressionWithSwitch() -> ContextualActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestAction()
        case 1:
            TestAction()
        default:
            TestAction()
        }
    }

    @ContextualActionsContentBuilder
    static func expressionWithIfAvailable() -> ContextualActionsContent {
        if #available(tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
