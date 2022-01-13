import SwiftUI
import shared

extension Notification.Name {
    
    static let articleGotTagged = Notification.Name("ArticleWasTagged")
    
}

struct ArticlesByTag: View {

    let tag: Tag
    let articleTagged = NotificationCenter.default.publisher(for: Notification.Name.articleGotTagged)
    @StateObject var viewModel = ObservableByTagsViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.tagsState) { (articles: TagViewState) in
            List {
                ForEach(articles.articles) { article in
                    ArticleItemView(article: article)
                        .swipeActions {
                            Button("Archive") {
                                Task {
                                    await viewModel.archive(article.id)
                                }
                            }
                            .tint(.red)
                        }
                }
            }.font(.system(.body, design: .rounded))
        }
        .listStyle(.plain)
        .navigationTitle(tag.name.isEmpty ? "Untagged" : tag.name)
        .task {
            await viewModel.loadArticles(tagged: tag)
        }
        .onReceive(articleTagged) { notification in
            viewModel.articleWasArchived(notification.userInfo!["articleId"] as! String)
        }
    }

}

struct ArticleItemView: View {
    
    let article: Article
    
    var body: some View {
        Link(destination: URL(string: article.url)!) {
            HStack(alignment: .center) {
                RemoteImage(url: article.mainImage()?.src, showsSpinner: false)
                    .frame(width: 100, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.system(.body, design: .rounded))
                    Text(article.excerpt)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary)
            }
            .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
        .onDrag { NSItemProvider(object: article.id as NSString) }
    }
    
}

struct CardStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 8))
    }
}

extension ViewModifier where Self == CardStyle {
    
    static var card: CardStyle  {
        CardStyle()
    }
    
}

extension MainScreenViewModel {

    static var standard: MainScreenViewModel {
        let api = PocketApi()
        let userStore = UserDefaultsStore()
        return MainScreenViewModel(
            pocketApi: api,
            tagsRepository: TagsFromArticlesRepository(pocketApi: api, userStore: userStore),
            userStore: userStore
        )
    }

}
