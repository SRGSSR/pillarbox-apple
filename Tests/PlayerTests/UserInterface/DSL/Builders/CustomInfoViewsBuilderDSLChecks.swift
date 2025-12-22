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

    @CustomInfoViewsContentBuilder
    static func oneExpression() -> CustomInfoViewsContent {
        view()
    }

    @CustomInfoViewsContentBuilder
    static func severalExpressions() -> CustomInfoViewsContent {
        view()
        view()
        view()
        view()
        view()
    }

    @CustomInfoViewsContentBuilder
    static func ifStatement() -> CustomInfoViewsContent {
        if true {
            view()
        }
    }

    @CustomInfoViewsContentBuilder
    static func ifElseStatements() -> CustomInfoViewsContent {
        if true {
            view()
        }
        else {
            view()
        }
    }

    @CustomInfoViewsContentBuilder
    static func switchStatement() -> CustomInfoViewsContent {
        switch Int.random(in: 0...2) {
        case 0:
            view()
        case 1:
            view()
        default:
            view()
        }
    }

    @CustomInfoViewsContentBuilder
    static func ifElseAvailableStatements() -> CustomInfoViewsContent {
        if #available(iOS 16, tvOS 16, *) {
            view()
        }
        else {
            view()
        }
    }

    @CustomInfoViewsContentBuilder
    static func forEachStatements() -> CustomInfoViewsContent {
        for _ in 1...10 {
            view()
        }
    }
}
