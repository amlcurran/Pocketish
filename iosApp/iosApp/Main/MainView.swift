import SwiftUI
import shared

enum OpenIn: Int {
    case safari
    case app
}

struct MainViewState2: Equatable {
    let latestUntagged: [ArticleResponse]
    let tags: [TagResponse]
}

extension MainViewState {
    
    var asNewState: MainViewState2 {
        MainViewState2(latestUntagged: latestUntagged.map(\.asArticle), tags: tags.map(\.asTag))
    }
    
}

struct MainView: View {

    let state: MainViewState2
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
                ForEach(state.tags) { tag in
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

import shared

extension Article {
    
    var definitelyTitle: String {
        if title.isEmpty {
            return " "
        } else {
            return title
        }
    }
    
    var asArticle: ArticleResponse {
        ArticleResponse(itemId: id,
                        resolvedTitle: self.definitelyTitle,
                        tags: self.tags?.mapValues { TagResponse(itemId: $0.itemId) },
                        resolvedUrl: URL(string: self.url)!,
                        excerpt: self.excerpt,
                        images: images.mapValues { ArticleResponse.Image(src: $0.src) })
    }
    
}

extension Tag {
    
    var asTag: TagResponse {
        TagResponse(itemId: self.id)
    }
}

struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            MainView(state: MainViewState2(
                latestUntagged: [
                    ArticleResponse(itemId: "abc", resolvedTitle: "An article", tags: nil, resolvedUrl: URL(string: "https://foo.com")!, excerpt: "Blah Blah blah", images: [:])
                ], tags: [
                    TagResponse(itemId: "foo"),
                    TagResponse(itemId: "bar")
                ])
            )
        }
    }
    
}
