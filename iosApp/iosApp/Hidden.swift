import SwiftUI

struct Hidden: View {

    @State var when: Bool
    let content: () -> AnyView

    var body: some View {
        if when {
            AnyView(content().hidden())
        } else {
            AnyView(content())
        }
    }

}
