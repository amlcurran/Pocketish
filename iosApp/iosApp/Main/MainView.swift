import SwiftUI

enum OpenIn: Int {
    case safari
    case app
}

struct MainViewState2: Equatable {
    let latestUntagged: [ArticleResponse]
    let tags: [TagResponse]
}

struct MainView: View {

    let state: MainViewState2
    let horizontalSize: UserInterfaceSizeClass?
    @State var showSheet: Sheet?
    @State var enteredArchiveDrop: Bool = false
    @State private var search = ""
    @AppStorage("openIn") var openIn: OpenIn = .safari
    @StateObject var viewModel = MainViewModel()
    @State var enteredNewDrop = false

    var body: some View {
        VStack {
            List {
                UntaggedView(
                    latestUntagged: state.latestUntagged,
                    compact: horizontalSize != .regular,
                    loadingMoreUntagged: $viewModel.loadingMoreUntagged,
                    onLoadMore: viewModel.loadMoreUntagged
                )
                ForEach(state.tags) { tag in
                    TagListItem(tag: tag) { articleId in
                        Task {
                            await viewModel.add(tag, toArticleWithId: articleId) {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                NotificationCenter.default.post(name: .articleGotTagged, object: nil, userInfo: ["articleId": articleId])
                            }
                        }
                    } destination: {
                        ArticlesByTag(tag: tag)
                    }
                    .onLongPressGesture {
                        showSheet = .addIcon(to: tag)
                    }
                }
                .listStyle(.plain)
                .animation(.default, value: state.tags)
            }
        }
        .sheet(item: $showSheet) { foo in
            foo.content(self)
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTag, object: nil), perform: { output in
            if let tagName = output.userInfo?["tagName"] as? String {
                viewModel.addedTag(named: tagName)
            }
        })
        .searchable(text: $search, prompt: "Find an article")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        Task {
                            await viewModel.forceRefresh()
                        }
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    Picker(selection: $openIn, label: Label("Open in", systemImage: "arrow.up.right.square")) {
                        Text("Safari")
                            .tag(OpenIn.safari)
                        Text("In-app")
                            .tag(OpenIn.app)
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Label("Archive", systemImage: "archivebox")
                        .tint(enteredArchiveDrop ? .white : .accentColor)
                }
                .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredArchiveDrop, droppedArticle: { articleId in
                    viewModel.archive(articleId) {
                        
                    }
                }))
                .background {
                    HoverBackground(entered: $enteredArchiveDrop)
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {

                } label: {
                    Label("New tag", systemImage: "plus.circle")
                }
                .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredNewDrop, droppedArticle: { articleId in
                    showSheet = .addNewTag(to: articleId)
                }))
                .background {
                    HoverBackground(entered: $enteredArchiveDrop)
                }

            }
        }
    }

}

struct HoverBackground: View {
    
    @Binding var entered: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(.accentColor)
            .opacity(entered ? 1 : 0)
            .scaleEffect(entered ? 1.0 : 0.6)
            .animation(.default.speed(2), value: entered)
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
                ]), horizontalSize: .regular
            )
        }
    }
    
}
