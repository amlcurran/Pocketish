import SwiftUI

struct AddNewTagView: View {

    @State var tagName: String = ""
    let onFinished: (String) -> Void
    @Environment(\.dismiss) var dismiss: DismissAction

    var body: some View {
        VStack {
            TextField("Foo", text: $tagName)
                .textFieldStyle(.roundedBorder)
            Button("Text") {
                onFinished(tagName)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

}

struct AddNewTagView_Preview: PreviewProvider {
    
    static var previews: some View {
        Group {
            NavigationView {
                AddNewTagView { _ in }
            }
        }
    }
    
}
