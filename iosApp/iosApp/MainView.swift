import SwiftUI
import shared

struct Sheet: Identifiable {
    static func showArticle(_ article: Article) -> Sheet {
        Sheet(id: "article-" + article.id) { _ in
            AnyView(SafariView(url: URL(string: article.url)!))
        }
    }

    static func addNewTag(to article: String) -> Sheet {
        Sheet(id: "newtag-" + article) { mainView in
            AnyView(AddNewTagView { tagName in
                mainView.showSheet = nil
                mainView.viewModel.addNewTag(named: tagName, to: article) {
                    mainView.selectedFeedback.notificationOccurred(.success)
                }
            })
        }
    }

    let id: String
    let content: (MainView) -> AnyView
}

struct MainView: View {

    let state: MainViewState
    @State var showSheet: Sheet?
    @State var enteredNewDrop: Bool = false
    @State var enteredArchiveDrop: Bool = false
    @State var enteredTagDrop: Bool = false
    @State var dragClicked: Bool = false
    @StateObject var viewModel: ObservableHomeViewModel

    let selectedFeedback = UINotificationFeedbackGenerator()

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
            VStack {
                HStack {
                    Button("Archive") {
                        dragClicked = true
                    }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredArchiveDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: $enteredArchiveDrop, droppedArticle: { articleId in
                        viewModel.archive(articleId) {

                        }
                    }))
                    Button("Add new tag") {
                        dragClicked = true
                    }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: $enteredNewDrop, droppedArticle: { articleId in
                        showSheet = .addNewTag(to: articleId)
                    }))
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
        }
        .listStyle(PlainListStyle())
        .sheet(item: $showSheet) { foo in
            foo.content(self)
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
        .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(dropEntered: $enteredTagDrop) { articleId in
                viewModel.add(tag, toArticleWithId: articleId) {
                    selectedFeedback.notificationOccurred(.success)
                }
            })
    }

}

