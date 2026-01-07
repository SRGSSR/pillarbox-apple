//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private enum CustomInfoViewsBuilderDSLChecks {
    private static func view() -> PillarboxPlayer.Tab {
        Tab(title: "Title") {
            Button("") {}
        }
    }

    @InfoViewTabsContentBuilder
    static func oneExpression() -> InfoViewTabsContent {
        view()
    }

    @InfoViewTabsContentBuilder
    static func severalExpressions() -> InfoViewTabsContent {
        view()
        view()
        view()
        view()
        view()
    }

    @InfoViewTabsContentBuilder
    static func ifStatement() -> InfoViewTabsContent {
        if true {
            view()
        }
    }

    @InfoViewTabsContentBuilder
    static func ifElseStatements() -> InfoViewTabsContent {
        if true {
            view()
        }
        else {
            view()
        }
    }

    @InfoViewTabsContentBuilder
    static func switchStatement() -> InfoViewTabsContent {
        switch Int.random(in: 0...2) {
        case 0:
            view()
        case 1:
            view()
        default:
            view()
        }
    }

    @InfoViewTabsContentBuilder
    static func ifElseAvailableStatements() -> InfoViewTabsContent {
        if #available(iOS 16, tvOS 16, *) {
            view()
        }
        else {
            view()
        }
    }

    @InfoViewTabsContentBuilder
    static func forEachStatements() -> InfoViewTabsContent {
        for _ in 1...10 {
            view()
        }
    }
}
