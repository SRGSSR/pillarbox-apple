//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum InfoViewActionsContentBuilderDSLChecks {
    private static func TestAction() -> any InfoViewActionsElement {
        Button("") {}
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
    static func ifStatement() -> InfoViewActionsContent {
        if true {
            TestAction()
        }
    }

    @InfoViewActionsContentBuilder
    static func ifElseStatements() -> InfoViewActionsContent {
        if true {
            TestAction()
        }
        else {
            TestAction()
        }
    }

    @InfoViewActionsContentBuilder
    static func switchStatement() -> InfoViewActionsContent {
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
    static func ifElseAvailableStatements() -> InfoViewActionsContent {
        if #available(iOS 16, tvOS 16, *) {
            TestAction()
        }
        else {
            TestAction()
        }
    }
}
