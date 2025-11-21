//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum SystemVideoViewActionsContentBuilder7CompilationChecks {
    private static func Action() -> SystemVideoViewAction {
        SystemVideoViewAction(title: "") {}
    }

    @SystemVideoViewActionsContentBuilder7
    static func oneExpression() -> SystemVideoViewActionsContent {
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func twoExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func threeExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func fourExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func fiveExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
        Action()
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func sixExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
        Action()
        Action()
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func sevenExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
        Action()
        Action()
        Action()
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder7
    static func expressionWithIfOnly() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder7
    static func expressionWithNestedIf() -> SystemVideoViewActionsContent {
        if true {
            if true {
                Action()
            }
        }
    }

    @SystemVideoViewActionsContentBuilder7
    static func expressionWithIfElse() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder7
    static func expressionWithSwitch() -> SystemVideoViewActionsContent {
        switch Int.random(in: 0...2) {
        case 0:
            Action()
        case 1:
            Action()
        default:
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder7
    static func expressionWithIfAvailable() -> SystemVideoViewActionsContent {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
