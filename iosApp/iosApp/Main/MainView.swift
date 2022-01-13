import SwiftUI
import shared

struct UntaggedView: View {
    
    let latestUntagged: [Article]
    let compact: Bool
    @Binding var loadingMoreUntagged: Bool
    let onLoadMore: () -> Void
    @Environment(\.openURL) var openURL: OpenURLAction
    
    var body: some View {
        if compact {
            HorizontalArticles(articles: latestUntagged,
                               loadingMore: $loadingMoreUntagged,
                               onEndClicked: onLoadMore) { article in
                openURL(URL(string: article.url)!)
            }
        } else {
            NavigationLink("Untagged") {
                ArticlesByTag(tag: Tag.companion.untagged)
            }
        }
    }
    
}

struct MainView: View {

    let state: MainViewState
    @State var showSheet: Sheet?
    @StateObject var viewModel = ObservableMainViewModel(homeViewModel: .standard)
    @Environment(\.horizontalSizeClass) var horizontalSize: UserInterfaceSizeClass?

    let selectedFeedback = UINotificationFeedbackGenerator()

    var body: some View {
        VStack {
            List {
                UntaggedView(
                    latestUntagged: state.latestUntagged,
                    compact: horizontalSize == .compact,
                    loadingMoreUntagged: $viewModel.loadingMoreUntagged,
                    onLoadMore: viewModel.loadMoreUntagged
                )
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
