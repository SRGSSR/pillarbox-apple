//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private enum CustomInfoViewsBuilderDSLChecks {
    private static func view() -> CustomInfoView {
        CustomInfoView(title: "Title") {
            Button("") {}
        }
    }

    @CustomInfoViewsBuilder
    static func oneExpression() -> [CustomInfoView] {
        view()
    }

    @CustomInfoViewsBuilder
    static func severalExpressions() -> [CustomInfoView] {
        view()
        view()
        view()
        view()
        view()
    }

    @CustomInfoViewsBuilder
    static func ifStatement() -> [CustomInfoView] {
        if true {
            view()
        }
    }

    @CustomInfoViewsBuilder
    static func ifElseStatements() -> [CustomInfoView] {
        if true {
            view()
        }
        else {
            view()
        }
    }

    @CustomInfoViewsBuilder
    static func switchStatement() -> [CustomInfoView] {
        switch Int.random(in: 0...2) {
        case 0:
            view()
        case 1:
            view()
        default:
            view()
        }
    }

    @CustomInfoViewsBuilder
    static func ifElseAvailableStatements() -> [CustomInfoView] {
        if #available(iOS 16, tvOS 16, *) {
            view()
        }
        else {
            view()
        }
    }

    @CustomInfoViewsBuilder
    static func forEachStatements() -> [CustomInfoView] {
        for _ in 1...10 {
            view()
        }
    }
}
