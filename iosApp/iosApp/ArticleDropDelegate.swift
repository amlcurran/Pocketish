import SwiftUI

class ArticleDropDelegate: DropDelegate {

    private let droppedArticle: (String) -> Void
    private let dropEntered: (Bool) -> Void
    private let dragOverFeedback = UISelectionFeedbackGenerator()

    init(dropEntered: @escaping (Bool) -> Void = { _ in }, droppedArticle: @escaping (String) -> ()) {
        self.dropEntered = dropEntered
        self.droppedArticle = droppedArticle
    }

    func dropEntered(info: DropInfo) {
        dragOverFeedback.selectionChanged()
        self.dropEntered(true)
    }

    func dropExited(info: DropInfo) {
        self.dropEntered(false)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.dropEntered(false)
        info.itemProviders(for: ["public.text"]).first?.loadItem(forTypeIdentifier: "public.text") { coding, error in
            if let data = coding as? Data, let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.droppedArticle(string)
                }
            }
        }
        return true
    }

}
