import SwiftUI
import shared

struct ArticlesByTag: View {

    let tag: Tag
    @StateObject var viewModel: ObservableHomeViewModel = ObservableHomeViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.tagsState) { (articles: TagViewState) in
            List(articles.articles) { (article: Article) in
                Text(article.title)
            }
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