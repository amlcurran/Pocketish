import SwiftUI
import shared

class Foo: ObservableObject {
    @Published var article: Article?
}

struct MainView: View {

    let state: MainViewState
    @State var showingArticle: Bool = false
    @State var addingNewTag: Bool = false
    @State var addingNewTagToArticle: String?
    @State var enteredNewDrop: Bool = false
    @State var dragClicked: Bool = false
    @StateObject var viewModel: ObservableHomeViewModel
    @StateObject var foo = Foo()

    private let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged) {
                    viewModel.loadMoreUntagged()
                } onArticleClicked: { article in
                    foo.article = article
                    showingArticle = true
                }
                ForEach(state.tags) { (tag: Tag) in
                    tagListItem(from: tag)
                    if tag.id != state.tags.last?.id {
                        Divider()
                    }
                }
                Rectangle()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(height: 50)
            }
            Button("Add new tag") {
                dragClicked = true
            }
            .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
            .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: { entered in
                enteredNewDrop = entered
            }, droppedArticle: { articleId in
                addingNewTagToArticle = articleId
                addingNewTag = true
            }))
        }
            .listStyle(PlainListStyle())
            .sheet(isPresented: $showingArticle) {
                if let article = foo.article {
                    SafariView(url: URL(string: article.url)!)
                } else {
                    fatalError("No article to show")
                }
            }
            .sheet(isPresented: $addingNewTag) {
                AddNewTagView { tagName in
                    self.addingNewTag = false
                    viewModel.addNewTag(named: tagName, to: addingNewTagToArticle!) {
                        selectedFeedback.notificationOccurred(.success)
                    }
                }
            }
        .alert(isPresented: $dragClicked) {
            Alert(title: Text("Add new tag"),
                message: Text("Drag an article on the button to create a new tag"),
                dismissButton: .default(Text("OK")))
        }
    }

    private func tagListItem(from tag: Tag) -> some View {
        NavigationLink(destination: ArticlesByTag(tag: tag)) {
            ListItem(leftText: tag.name,
                rightText: "\(tag.numberOfArticles)",
                rightImage: Image(systemName: "chevron.right"))
        }
            .onDrop(of: ["public.text"], delegate: ArticleDropDelegate { articleId in
                viewModel.add(tag, toArticleWithId: articleId) {
                    selectedFeedback.notificationOccurred(.success)
                }
            })
    }

}

