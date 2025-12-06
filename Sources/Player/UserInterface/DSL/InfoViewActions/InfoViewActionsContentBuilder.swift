@resultBuilder
public enum InfoViewActionsContentBuilder {
    public typealias Expression = any InfoViewActionsElement
    public typealias Component = [any InfoViewActionsElement]
    public typealias Result = InfoViewActionsContent

    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    
    public static func buildBlock() -> Component {
        []
    }

    public static func buildBlock(_ c0: Component) -> Component {
        c0
    }

    public static func buildBlock(_ c0: Component, _ c1: Component) -> Component {
        c0 + c1
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
        .init(children: component)
    }
}
