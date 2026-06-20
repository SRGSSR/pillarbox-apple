//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// TODO: Remove if Swift Data is improved.
/// Avoids "Failed to decode a composite attribute" crash when reading Swift Data model containing optional enums having
/// associated values.
enum SafeSwiftDataOptional<T> {
    case none
    case some(T)

    var wrappedValue: T? {
        switch self {
        case .none:
            return nil
        case let .some(t):
            return t
        }
    }

    init(wrappedValue: T?) {
        if let wrappedValue {
            self = .some(wrappedValue)
        }
        else {
            self = .none
        }
    }
}

extension SafeSwiftDataOptional: Codable where T: Codable {}
