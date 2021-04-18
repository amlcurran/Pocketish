import SwiftUI
import shared

class ArticleDropDelegate: DropDelegate {

    private let droppedArticle: (String) -> Void
    private let tag: Tag
    @Binding private var dropEntered: Tag?// (Bool) -> Void
    private let dragOverFeedback = UISelectionFeedbackGenerator()

    init(tag: Tag, dropEntered: Binding<Tag?>, droppedArticle: @escaping (String) -> ()) {
        self.tag = tag
        self._dropEntered = dropEntered
        self.droppedArticle = droppedArticle
    }

    func dropEntered(info: DropInfo) {
        dragOverFeedback.selectionChanged()
        dropEntered = tag
    }

    func dropExited(info: DropInfo) {
        dropEntered = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        dropEntered = nil
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

class ArticleDropDelegate2: DropDelegate {

    private let droppedArticle: (String) -> Void
    @Binding private var dropEntered: Bool
    private let dragOverFeedback = UISelectionFeedbackGenerator()

    init(dropEntered: Binding<Bool>, droppedArticle: @escaping (String) -> ()) {
        self._dropEntered = dropEntered
        self.droppedArticle = droppedArticle
    }

    func dropEntered(info: DropInfo) {
        dragOverFeedback.selectionChanged()
        dropEntered = true
    }

    func dropExited(info: DropInfo) {
        dropEntered = false
    }

    func performDrop(info: DropInfo) -> Bool {
        dropEntered = false
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
