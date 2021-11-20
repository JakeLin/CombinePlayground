import Foundation
import Combine

public func demo(of description: String, action: () -> Void) {
    print("\n——— Demo of:", description, "———")
    action()
}

public func getThreadName() -> String {
    if Thread.current.isMainThread {
        return "Main Thread"
    } else if let name = Thread.current.name {
        if name.isEmpty {
          return "Unnamed Thread"
        }
        return name
    } else {
        return "Unknown Thread"
    }
}
