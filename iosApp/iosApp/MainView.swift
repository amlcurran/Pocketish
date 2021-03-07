import SwiftUI
import shared

class Foo: ObservableObject {
    @Published var article: Article?
}

struct MainView: View {

    let state: MainViewState
    @State var isDraggingArticle: Bool = false
    @StateObject var viewModel: ObservableHomeViewModel
    @State var showingArticle: Bool = false
    @StateObject var foo = Foo()

    private let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged, isDragging: $isDraggingArticle) {
                    viewModel.loadMoreUntagged()
                } onArticleClicked: { article in
                    foo.article = article
                    showingArticle = true
                }
                ForEach(state.tags) { (tag: Tag) in
                    tagListItem(from: tag)
                    if isDraggingArticle || tag.id != state.tags.last?.id {
                        Divider()
                    }
                }
                if isDraggingArticle {
                    ListItem(leftText: "Add new tag",
                        rightText: "",
                        leftColor: .accentColor,
                        rightImage: Image(systemName: "plus.circle"))
                }
            }
            Hidden(when: isDraggingArticle) {
                AnyView(Button("Foo") {
                    print("Clicked")
                }
                    .buttonStyle(RoundedButtonStyle())
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate { articleId in
                        print("I'll add a new thing here")
                    })
                )
            }
        }.listStyle(PlainListStyle())
            .sheet(isPresented: $showingArticle) {
                if let article = foo.article {
                    SafariView(url: URL(string: article.url)!)
                } else {
                    fatalError("No article to show")
                }
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

