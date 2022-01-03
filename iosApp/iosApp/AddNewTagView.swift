import SwiftUI

struct AddNewTagView: View {

    @State var tagName: String = ""
    let onFinished: (String) -> Void

    var body: some View {
        VStack {
            TextField("Foo", text: $tagName)
            Button("Text") {
                onFinished(tagName)
            }
        }
        .padding()
    }

}

struct AddNewTagView_Preview: PreviewProvider {
    
    static var previews: some View {
        Group {
            AddNewTagView { _ in }
        }
    }
    
}
