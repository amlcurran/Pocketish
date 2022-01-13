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
    @Environment(\.horizontalSizeClass) var horizontalSize: UserInterfaceSizeClass?
    @StateObject var viewModel = ObservableMainViewModel(homeViewModel: .standard)

    let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        VStack {
            List {
                if horizontalSize != .regular {
                    HorizontalArticles(articles: state.latestUntagged,
                                       loadingMore: $viewModel.loadingMoreUntagged) {
                        viewModel.loadMoreUntagged()
                    } onArticleClicked: { article in
                        openURL(URL(string: article.url)!)
                    }
                } else {
                    NavigationLink("Untagged") {
                        ArticlesByTag(tag: Tag.companion.untagged)
                    }
                }
                ForEach(state.tags) { (tag: Tag) in
                    TagListItem(tag: tag) { articleId in
                        viewModel.add(tag, toArticleWithId: articleId) {
                            selectedFeedback.notificationOccurred(.success)
                        }
                    } destination: {
                        ArticlesByTag(tag: tag)
                    }
                }
            }
            DropView(showSheet: $showSheet) { articleId in
                viewModel.archive(articleId) {

                }
            }
        }
        .sheet(item: $showSheet) { foo in
            foo.content(self)
        }
    }

}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MainView(state: MainViewState(
                tags: [
                    Tag(id: "foo", name: "Foo"),
                    Tag(id: "bar", name: "Baz")
                ],
                latestUntagged: [
                    Article(id: "abc", title: "An article", tags: nil, url: "https://foo.com", excerpt: "Blah Blah blah", images: [:])
                ])
            )
        }
    }
    
}
