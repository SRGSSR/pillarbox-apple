//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer

private enum InfoViewActionsBuilderCompilationChecks {
    private static func Action() -> InfoViewAction {
        .init(title: "") {}
    }

    @InfoViewActionsBuilder
    static func singleExpression() -> [InfoViewAction] {
        Action()
    }

    @InfoViewActionsBuilder
    static func twoExpressions() -> [InfoViewAction] {
        Action()
        Action()
    }

    @InfoViewActionsBuilder
    static func expressionWithIfOnly() -> [InfoViewAction] {
        if true {
            Action()
        }
    }

    @InfoViewActionsBuilder
    static func expressionWithNestedIf() -> [InfoViewAction] {
        if true {
            if true {
                Action()
            }
        }
    }

    @InfoViewActionsBuilder
    static func expressionWithIfElse() -> [InfoViewAction] {
        if true {
            Action()
        }
        else {
            Action()
        }
    }

    @InfoViewActionsBuilder
    static func expressionWithIfAvailable() -> [InfoViewAction] {
        if #available(tvOS 16, *) {
            Action()
        }
        else {
            Action()
        }
    }
}
