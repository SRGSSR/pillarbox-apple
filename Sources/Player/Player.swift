import Combine

// MARK: Player

public final class Player: ObservableObject {
    @Published public private(set) var state: State = .idle
}

// MARK: Types

extension Player {
    public enum State: Equatable {
        case idle
        case playing
        case paused
        case ended
        case failed(error: Error)

        public static func == (lhs: Player.State, rhs: Player.State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.playing, .playing), (.paused, .paused),
                (.ended, .ended), (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }
}
