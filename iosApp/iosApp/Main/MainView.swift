import SwiftUI
import shared

struct MainView: View {

    let state: MainViewState
    @State var showSheet: Sheet?
    @State var enteredNewDrop: Bool = false
    @State var enteredArchiveDrop: Bool = false
    @State var enteredTagDrop: Tag? = nil
    @State var dragClicked: Bool = false
    @Environment(\.openURL) var openURL: OpenURLAction
    @StateObject var viewModel: ObservableHomeViewModel

    let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged, loadingMore: $viewModel.loadingMoreUntagged) {
                    viewModel.loadMoreUntagged()
                } onArticleClicked: { article in
                    openURL(URL(string: article.url)!)
                }
                ForEach(state.tags) { (tag: Tag) in
                    TagListItem(tag: tag) { articleId in
                        viewModel.add(tag, toArticleWithId: articleId) {
                            selectedFeedback.notificationOccurred(.success)
                        }
                    } destination: {
                        ArticlesByTag(tag: tag, viewModel: viewModel.duplicate())
                    }
                    if tag.id != state.tags.last?.id {
                        Divider()
                    }
                }
            }
            VStack {
                HStack {
                    Button("Archive") {
                        dragClicked = true
                    }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredArchiveDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredArchiveDrop, droppedArticle: { articleId in
                        viewModel.archive(articleId) {

                        }
                    }))
                    Button("Add new tag") {
                        dragClicked = true
                    }
                    .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredNewDrop, droppedArticle: { articleId in
                        showSheet = .addNewTag(to: articleId)
                    }))
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
        .listStyle(.plain)
        .sheet(item: $showSheet) { foo in
            foo.content(self)
        }
        .alert(isPresented: $dragClicked) {
            Alert(title: Text("Add new tag"),
                  message: Text("Drag an article on the button to create a new tag"),
                  dismissButton: .default(Text("OK")))
        }
    }

}
