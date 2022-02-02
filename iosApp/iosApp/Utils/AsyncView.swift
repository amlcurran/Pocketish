import SwiftUI

struct AsyncView2<T, Content: View>: View {

    var state: AsyncResult2<T>
    @ViewBuilder
    let builder: (T) -> Content

    var body: some View {
        switch state {
        case .success(let state):
            builder(state)
        case .loading:
            ProgressView()
        case .failure(_):
            ProgressView()
        }
    }

}
