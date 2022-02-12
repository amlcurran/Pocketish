import Foundation
import SwiftUI

class ObservableMainViewModel: ObservableObject {
    private let tagModel = ObservableByTagsViewModel()

    @Published var state: AsyncResult2<MainViewState2> = .loading
    @Published var loadingMoreUntagged: Bool = false

    func appeared() async throws {
        if case .success = state {
            print("not reloading")
        } else {
            await foo(ignoringCache: false)
        }
    }
    
    @MainActor
    private func foo(ignoringCache: Bool) async {
        state = .loading
        let latestUntagged = await tagModel.loadArticles(tagged: .untagged)
        var components = URLComponents(string: "https://getpocket.com/v3/get")!
        components.queryItems = [
            URLQueryItem(name: "consumer_key", value: consumerKey),
            URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
            URLQueryItem(name: "detailType", value: "complete")
        ]
        let request = URLRequest(url: components.url!)
        do {
            let data = try await URLSession.shared.run(request, as: ApiListResponse.self)
            print(data.list)
            let tags = Set(data.list
                .flatMap { Array(($0.value.tags ?? [:]).keys) })
            let mainViewState = MainViewState2(latestUntagged: latestUntagged?.articles ?? [],
                                               tags: Array(tags.map(TagResponse.init).sorted(by: \.id)))
            state = .success(mainViewState)
        } catch {
            state = .failure(error)
        }
    }

    func forceRefresh(onlyUntagged: Bool = false) async {
        await foo(ignoringCache: true)
    }

    func add(_ tag: TagResponse, toArticleWithId articleId: String, onFinished: @escaping () -> Void) {
        fatalError()
//        model.addTagToArticle(tag: tag.itemId, articleId: articleId) { result, _ in
//            if result?.boolValue == true {
//                NotificationCenter.default.post(name: .articleGotTagged, object: nil, userInfo: [
//                    "articleId": articleId
//                ])
//            }
//        }
    }

    func loadMoreUntagged() {
        fatalError()
//        loadingMoreUntagged = true
//        model.loadMoreUntagged { state, error in
//            self.loadingMoreUntagged = false
//        }
    }

    func archive(_ id: String, onFinished: @escaping () -> Void) {
        fatalError()
//        model.archive(articleId: id) { _, _ in
//            onFinished()
//        }
    }

    func addNewTag(named tagName: String, to articleId: String?, onFinished: @escaping () -> Void) {
        fatalError()
//        model.addTagToArticle(tag: tagName, articleId: articleId) { result, error in
//            onFinished()
//        }
    }
}

extension Notification.Name {
    
    static let articleGotTagged = Notification.Name("ArticleWasTagged")
    
}

extension Array {
    
    func sorted<Key: Comparable>(by comparator: KeyPath<Element, Key>) -> [Element] {
        sorted { first, second in
            first[keyPath: comparator] < second[keyPath: comparator]
        }
    }
    
}
