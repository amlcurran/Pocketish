import SwiftUI
import shared

struct ArticlesByTag: View {

    let tag: Tag
    @ObservedObject var viewModel = ObservableByTagsViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.tagsState) { (articles: TagViewState) in
            List {
                ForEach(articles.articles) { (article: Article) in
                    articleItem(article: article)
                }
                .onDelete { items in
                    let article = items.first.map { articles.articles[$0] }
                    viewModel.archive(article!.id) {

                    }
                }
            }.font(.system(.body, design: .rounded))
        }
            .navigationTitle(tag.name)
            .navigationBarTitle(tag.name)
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .task {
                await viewModel.loadArticles(tagged: tag)
            }
    }

    private func articleItem(article: Article) -> some View {
        Link(destination: URL(string: article.url)!) {
            HStack(alignment: .top) {
                RemoteImage(url: article.mainImage()?.src)
                    .frame(width: 100, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                VStack(alignment: .leading) {
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
