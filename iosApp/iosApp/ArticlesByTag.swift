import SwiftUI
import shared

struct ArticlesByTag: View {

    let tag: Tag
    @StateObject var viewModel: ObservableHomeViewModel = ObservableHomeViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.tagsState) { (articles: TagViewState) in
            List(articles.articles) { (article: Article) in
                Link(destination: URL(string: article.url)!) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(article.title)
                                .font(.system(.title3, design: .rounded))
                            Spacer(minLength: 6)
                            Text(article.excerpt)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                        }
                            .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                        Image(systemName: "chevron.forward")
                        .foregroundColor(.secondary)
                    }
                }
            }.font(.system(.body, design: .rounded))
        }
            .navigationTitle(tag.name)
            .navigationBarTitle(tag.name)
            .onAppear {
                viewModel.loadArticles(tagged: tag)
            }
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