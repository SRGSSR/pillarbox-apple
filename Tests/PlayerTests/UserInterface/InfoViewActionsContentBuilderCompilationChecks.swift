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
    static func singleExpression() -> SystemVideoViewActionsContent {
        Action()
    }

    @InfoViewActionsContentBuilder
    static func twoExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfOnly() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithNestedIf() -> SystemVideoViewActionsContent {
        if true {
            if true {
                Action()
            }
        }
    }

    @InfoViewActionsContentBuilder
    static func expressionWithIfElse() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @InfoViewActionsContentBuilder
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

    @InfoViewActionsContentBuilder
    static func expressionWithIfAvailable() -> SystemVideoViewActionsContent {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
