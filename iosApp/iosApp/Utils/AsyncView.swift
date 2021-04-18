import SwiftUI

struct AsyncView<T: Equatable, Content: View>: View {

    var state: AsyncResult<T>
    let builder: (T) -> Content

    var body: some View {
        print(state)
        switch state {
        case .loading, .idle, .failure:
            return AnyView(ProgressView())
        case .data(let state):
            return AnyView(builder(state))
        }
    }

}
