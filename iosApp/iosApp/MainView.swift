import SwiftUI
import shared

struct MainView: View {

    enum Sheet: Identifiable {
        case showArticle(Article)
        case addNewTag(String)

        var id: String {
            switch self {
            case .showArticle(let article):
                return "article-" + article.id
            case .addNewTag(let articleId):
                return "newtag-" + articleId
            }
        }
    }

    let state: MainViewState
    @State var showSheet: Sheet?
    @State var enteredNewDrop: Bool = false
    @State var dragClicked: Bool = false
    @StateObject var viewModel: ObservableHomeViewModel

    private let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged) {
                    viewModel.loadMoreUntagged()
                } onArticleClicked: { article in
                    showSheet = .showArticle(article)
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
            HStack {
                Button("Archive") {
                    dragClicked = true
                }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: { entered in
                        enteredNewDrop = entered
                    }, droppedArticle: { articleId in
                        viewModel.archive(articleId) {

                        }
                    }))
                Button("Add new tag") {
                    dragClicked = true
                }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: { entered in
                        enteredNewDrop = entered
                    }, droppedArticle: { articleId in
                        showSheet = .addNewTag(articleId)
                    }))
            }
        }
            .listStyle(PlainListStyle())
            .sheet(item: $showSheet) { foo in
                switch foo {
                case .addNewTag(let id):
                    AddNewTagView { tagName in
                        self.showSheet = nil
                        viewModel.addNewTag(named: tagName, to: id) {
                            selectedFeedback.notificationOccurred(.success)
                        }
                    }
                case .showArticle(let article):
                    SafariView(url: URL(string: article.url)!)
                }
            }
        .alert(isPresented: $dragClicked) {
            Alert(title: Text("Add new tag"),
                message: Text("Drag an article on the button to create a new tag"),
                dismissButton: .default(Text("OK")))
        }
    }

    private func tagListItem(from tag: Tag) -> some View {
        NavigationLink(destination: ArticlesByTag(tag: tag, viewModel: viewModel)) {
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

