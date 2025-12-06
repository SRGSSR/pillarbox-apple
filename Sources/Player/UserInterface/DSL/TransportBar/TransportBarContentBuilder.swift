@resultBuilder
public enum TransportBarContentBuilder {
    public typealias Expression = any TransportBarElement
    public typealias Component = [any TransportBarElement]
    public typealias Result = TransportBarContent

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

    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component) -> Component {
        c0 + c1 + c2
    }

    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component) -> Component {
        c0 + c1 + c2 + c3
    }

    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component, _ c4: Component) -> Component {
        c0 + c1 + c2 + c3 + c4
    }

    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component, _ c4: Component, _ c5: Component) -> Component {
        c0 + c1 + c2 + c3 + c4 + c5
    }

    public static func buildBlock(
        _ c0: Component,
        _ c1: Component,
        _ c2: Component,
        _ c3: Component,
        _ c4: Component,
        _ c5: Component,
        _ c6: Component
    ) -> Component {
        c0 + c1 + c2 + c3 + c4 + c5 + c6
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
