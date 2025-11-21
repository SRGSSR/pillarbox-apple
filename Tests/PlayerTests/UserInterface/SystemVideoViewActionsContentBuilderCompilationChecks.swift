//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum SystemVideoViewActionsContentBuilderCompilationChecks {
    private static func Action() -> SystemVideoViewAction {
        .init(title: "") {}
    }

    @SystemVideoViewActionsContentBuilder
    static func singleExpression() -> SystemVideoViewActionsContent {
        Action()
    }

    @SystemVideoViewActionsContentBuilder
    static func twoExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder
    static func expressionWithIfOnly() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder
    static func expressionWithNestedIf() -> SystemVideoViewActionsContent {
        if true {
            if true {
                Action()
            }
        }
    }

    @SystemVideoViewActionsContentBuilder
    static func expressionWithIfElse() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder
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

    @SystemVideoViewActionsContentBuilder
    static func expressionWithIfAvailable() -> SystemVideoViewActionsContent {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
