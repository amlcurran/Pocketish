import SwiftUI

struct ArticlesByTag: View {

    let tag: TagResponse
    let articleTagged = NotificationCenter.default.publisher(for: Notification.Name.articleGotTagged)
    @StateObject var viewModel = ArticlesByTagViewModel()

    var body: some View {
        AsyncView2(state: viewModel.tagsState) { (articles: TagViewState2) in
            List {
                ForEach(articles.articles) { article in
                    ArticleItemView(article: article)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.archive(article.id)
                                }
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                        }
                }
            }.font(.system(.body, design: .rounded))
                .animation(.default.speed(4), value: articles.articles)
        }
        .listStyle(.plain)
        .navigationTitle(
            tag.name + viewModel.tagsState.titleExtension
        )
        .task {
            await viewModel.loadArticles(tagged: tag)
        }
        .onReceive(articleTagged) { notification in
            viewModel.articleWasArchived(notification.userInfo!["articleId"] as! String)
        }
    }

}

private extension AsyncResult2 where Element == TagViewState2 {
    
    var titleExtension: String {
        switch self {
        case .success(let result):
            return " (\(result.articles.count))"
        default:
            return ""
        }
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
