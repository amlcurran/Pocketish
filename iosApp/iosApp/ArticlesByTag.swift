import SwiftUI
import shared

struct ArticlesByTag: View {

    let tag: Tag
    @StateObject var viewModel: ObservableHomeViewModel = ObservableHomeViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.tagsState) { (articles: TagViewState) in
            List {
                ForEach(articles.articles) { (article: Article) in
                    articleItem(article: article)
                }
                .onDelete { items in
                    print("Don't do anything yet!")
                }
            }.font(.system(.body, design: .rounded))
        }
            .navigationTitle(tag.name)
            .navigationBarTitle(tag.name)
            .onAppear {
                viewModel.loadArticles(tagged: tag)
            }
    }

    private func articleItem(article: Article) -> some View {
        Link(destination: URL(string: article.url)!) {
            HStack {
                RemoteImage(url: article.mainImage()?.src)
                    .frame(width: 100)
                    .clipped()
                VStack(alignment: .leading) {
                    Text(article.title)
                        .font(.system(.body, design: .rounded))
                    Text(article.excerpt)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                    .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary)
            }
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
