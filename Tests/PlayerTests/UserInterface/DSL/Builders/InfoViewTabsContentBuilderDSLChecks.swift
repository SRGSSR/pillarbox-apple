//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import SwiftUI

private enum InfoViewTabsContentBuilderDSLChecks {
    private static func tab() -> InfoViewTabsElement {
        Tab(title: "Title") {
            Button("") {}
        }
    }

    @InfoViewTabsContentBuilder
    static func oneExpression() -> InfoViewTabsContent {
        tab()
    }

    @InfoViewTabsContentBuilder
    static func severalExpressions() -> InfoViewTabsContent {
        tab()
        tab()
        tab()
        tab()
        tab()
    }

    @InfoViewTabsContentBuilder
    static func ifStatement() -> InfoViewTabsContent {
        if true {
            tab()
        }
    }

    @InfoViewTabsContentBuilder
    static func ifElseStatements() -> InfoViewTabsContent {
        if true {
            tab()
        }
        else {
            tab()
        }
    }

    @InfoViewTabsContentBuilder
    static func switchStatement() -> InfoViewTabsContent {
        switch Int.random(in: 0...2) {
        case 0:
            tab()
        case 1:
            tab()
        default:
            tab()
        }
    }

    @InfoViewTabsContentBuilder
    static func ifElseAvailableStatements() -> InfoViewTabsContent {
        if #available(iOS 16, tvOS 16, *) {
            tab()
        }
        else {
            tab()
        }
    }

    @InfoViewTabsContentBuilder
    static func forEachStatements() -> InfoViewTabsContent {
        for _ in 1...10 {
            tab()
        }
    }
}
