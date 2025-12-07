//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum ContextualActionsContentBuilderDSLChecks {
    private static func TestButton() -> any ContextualActionsElement {
        Button("") {}
    }

    @ContextualActionsContentBuilder
    static func oneExpression() -> ContextualActionsContent {
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func twoExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func threeExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func fourExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func fiveExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func sixExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func sevenExpressions() -> ContextualActionsContent {
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
        TestButton()
    }

    @ContextualActionsContentBuilder
    static func ifStatement() -> ContextualActionsContent {
        if true {
            TestButton()
        }
    }

    @ContextualActionsContentBuilder
    static func ifElseStatements() -> ContextualActionsContent {
        if true {
            TestButton()
        }
        else {
            TestButton()
        }
    }

    @ContextualActionsContentBuilder
    static func switchStatement() -> ContextualActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestButton()
        case 1:
            TestButton()
        default:
            TestButton()
        }
    }

    @ContextualActionsContentBuilder
    static func ifElseAvailableStatements() -> ContextualActionsContent {
        if #available(iOS 16, tvOS 16, *) {
            TestButton()
        }
        else {
            TestButton()
        }
    }
}
