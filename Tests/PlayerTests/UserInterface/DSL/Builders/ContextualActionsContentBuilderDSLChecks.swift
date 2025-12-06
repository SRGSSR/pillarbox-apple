//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum ContextualActionsContentBuilderDSLChecks {
    private static func TestAction() -> any ContextualActionsElement {
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
    static func ifStatement() -> ContextualActionsContent {
        if true {
            TestAction()
        }
    }

    @ContextualActionsContentBuilder
    static func ifElseStatements() -> ContextualActionsContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @ContextualActionsContentBuilder
    static func switchStatement() -> ContextualActionsContent {
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
    static func ifElseAvailableStatements() -> ContextualActionsContent {
        if #available(iOS 16, tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
