//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum InfoViewActionsContentBuilderCompilationChecks {
    private static func Action() -> SystemVideoViewAction {
        .init(title: "") {}
    }

    @InfoViewActionsContentBuilder
    static func singleExpression() -> InfoViewActionsContent {
        Action()
    }

    @InfoViewActionsContentBuilder
    static func twoExpressions() -> InfoViewActionsContent {
        Action()
        Action()
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfOnly() -> InfoViewActionsContent {
        if true {
            Action()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithNestedIf() -> InfoViewActionsContent {
        if true {
            if true {
                Action()
            }
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfElse() -> InfoViewActionsContent {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithSwitch() -> InfoViewActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            Action()
        case 1:
            Action()
        default:
            Action()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfAvailable() -> InfoViewActionsContent {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
