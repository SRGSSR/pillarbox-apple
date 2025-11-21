//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

// swiftlint:disable:next type_name
private enum SystemVideoViewActionsContentBuilder2CompilationChecks {
    private static func Action() -> SystemVideoViewAction {
        SystemVideoViewAction(title: "", identifier: .init(rawValue: "")) {}
    }

    @SystemVideoViewActionsContentBuilder2
    static func oneExpression() -> SystemVideoViewActionsContent {
        Action()
    }

    @SystemVideoViewActionsContentBuilder2
    static func twoExpressions() -> SystemVideoViewActionsContent {
        Action()
        Action()
    }

    @SystemVideoViewActionsContentBuilder2
    static func expressionWithIfOnly() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder2
    static func expressionWithNestedIf() -> SystemVideoViewActionsContent {
        if true {
            if true {
                Action()
            }
        }
    }

    @SystemVideoViewActionsContentBuilder2
    static func expressionWithIfElse() -> SystemVideoViewActionsContent {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @SystemVideoViewActionsContentBuilder2
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

    @SystemVideoViewActionsContentBuilder2
    static func expressionWithIfAvailable() -> SystemVideoViewActionsContent {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
