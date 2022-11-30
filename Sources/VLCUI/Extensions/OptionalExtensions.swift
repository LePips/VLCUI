import Foundation

extension Optional {

    func chaining(_ value: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return value
        case let .some(wrapped):
            return wrapped
        }
    }
}
