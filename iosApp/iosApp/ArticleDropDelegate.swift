import SwiftUI

class ArticleDropDelegate: DropDelegate {

    private let droppedArticle: (String) -> Void
    private let dragOverFeedback = UISelectionFeedbackGenerator()

    init(droppedArticle: @escaping (String) -> ()) {
        self.droppedArticle = droppedArticle
    }

    func dropEntered(info: DropInfo) {
        dragOverFeedback.selectionChanged()
    }

    func performDrop(info: DropInfo) -> Bool {
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
