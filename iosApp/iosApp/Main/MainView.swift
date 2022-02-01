import SwiftUI
import shared

enum OpenIn: Int {
    case safari
    case app
}

struct MainView: View {

    let state: MainViewState
    @State var showSheet: Sheet?
    @State private var search = ""
    @AppStorage("openIn") var openIn: OpenIn = .safari
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
        .searchable(text: $search, prompt: "Find an article")
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker(selection: $openIn, label: Label("Open in", systemImage: "arrow.up.right.square")) {
                        Text("Safari")
                            .tag(OpenIn.safari)
                        Text("In-app")
                            .tag(OpenIn.app)
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
            }
            ToolbarItem {
                Button(action: {
                    Task {
                        await viewModel.forceRefresh()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
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
