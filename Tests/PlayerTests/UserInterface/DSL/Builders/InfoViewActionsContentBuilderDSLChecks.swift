//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum InfoViewActionsContentBuilderDSLChecks {
    private static func TestButton() -> any InfoViewActionsElement {
        Button("") {}
    }

    @InfoViewActionsContentBuilder
    static func oneExpression() -> InfoViewActionsContent {
        TestButton()
    }

    @InfoViewActionsContentBuilder
    static func twoExpressions() -> InfoViewActionsContent {
        TestButton()
        TestButton()
    }

    @InfoViewActionsContentBuilder
    static func ifStatement() -> InfoViewActionsContent {
        if true {
            TestButton()
        }
    }

    @InfoViewActionsContentBuilder
    static func ifElseStatements() -> InfoViewActionsContent {
        if true {
            TestButton()
        }
        else {
            TestButton()
        }
    }

    @InfoViewActionsContentBuilder
    static func switchStatement() -> InfoViewActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            TestButton()
        case 1:
            TestButton()
        default:
            TestButton()
        }
    }

    @InfoViewActionsContentBuilder
    static func ifElseAvailableStatements() -> InfoViewActionsContent {
        if #available(iOS 16, tvOS 16, *) {
            TestButton()
        }
        else {
            TestButton()
        }
    }
}
