@resultBuilder
public enum PickerContentBuilder<Value> {
    public typealias Expression = any PickerElement<Value>
    public typealias Component = [any PickerElement<Value>]
    public typealias Result = PickerContent<Value>

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

    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap(\.self)
    }

    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component)
    }
}
