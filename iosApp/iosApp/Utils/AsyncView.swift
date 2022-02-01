import SwiftUI
import shared

struct AsyncView<T: AnyObject, Content: View>: View {

    var state: AsyncResult<T>
    @ViewBuilder
    let builder: (T) -> Content

    var body: some View {
        var foo: AnyView!
        state.handle { state in
            foo = AnyView(builder(state!))
        } onLoading: {
            foo = AnyView(ProgressView())
        } onError: { _ in
            foo = AnyView(ProgressView())
        }
        return foo
    }

}

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
