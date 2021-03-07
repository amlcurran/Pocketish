import SwiftUI

struct Padding {
    let value: CGFloat

    static let half = Padding(value: 4)
    static let full = Padding(value: 12)
    static let large = Padding(value: 12)
}

extension EdgeInsets {

    static func foo(_ set: [NSDirectionalRectEdge]) -> EdgeInsets {
        var insets = EdgeInsets()
        if set.contains(.leading) {
            insets.leading = Padding.full.value
        }
        if set.contains(.top) {
            insets.top = Padding.full.value
        }
        if set.contains(.trailing) {
            insets.trailing = Padding.full.value
        }
        if set.contains(.bottom) {
            insets.bottom = Padding.full.value
        }
        return insets
    }

}