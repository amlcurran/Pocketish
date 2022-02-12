import SwiftUI

struct AddNewTagView<Content: View>: View {

    @State var tagName: String = ""
    let onFinished: (String) -> Void
    let content: (String) -> Content
    @Environment(\.dismiss) var dismiss: DismissAction

    var body: some View {
        VStack {
            content(tagName)
                .animation(.easeInOut.speed(4), value: tagName)
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
                AddNewTagView { _ in } content: { _ in
                    Image(systemName: "paintpalette")
                }
            }
            .previewDevice("iPhone 13 mini")
        }
    }
    
}
