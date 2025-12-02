//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@resultBuilder
public enum SelectionMenuContentBuilder {
    public typealias Expression = SelectionMenuElement
    public typealias Component = [Expression]
    public typealias Result = MenuContent

    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap(\.self)
    }

    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }

    public static func buildEither(first component: Component) -> Component {
        component
    }

    public static func buildEither(second component: Component) -> Component {
        component
    }

    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component.map { $0.toUIMenuElement() })
    }
}
