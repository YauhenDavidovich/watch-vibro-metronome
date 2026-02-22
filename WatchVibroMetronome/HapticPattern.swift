import Foundation
import WatchKit

enum HapticPattern {
    static func play(isStrongBeat: Bool) {
        if isStrongBeat {
            WKInterfaceDevice.current().play(.directionUp)
        } else {
            WKInterfaceDevice.current().play(.click)
        }
    }
}
