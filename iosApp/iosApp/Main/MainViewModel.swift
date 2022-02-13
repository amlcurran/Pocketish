import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    private let tagModel = ArticlesByTagViewModel()

    @Published var state: AsyncResult2<MainViewState2> = .loading
    @Published var loadingMoreUntagged: Bool = false

    func appeared() async throws {
        if case .success = state {
            print("not reloading")
        } else {
            await loadArticles(ignoringCache: false)
        }
    }
    
    @MainActor
    private func loadArticles(ignoringCache: Bool) async {
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
        await loadArticles(ignoringCache: true)
    }

    @MainActor
    func add(_ tag: TagResponse, toArticleWithId articleId: String, onFinished: @escaping () -> Void) async {
        do {
            var components = URLComponents(string: "https://getpocket.com/v3/send")!
            components.queryItems = [
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
                URLQueryItem(name: "actions", value: """
[{ "action": "tags_add", "item_id": "\(articleId)", "tags": "\(tag.id)" }]
""")
            ]
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(ActionResponse.self, from: data)
            if response.actionResults.allSatisfy({ $0 }) {
                onFinished()
            }
        } catch {
            print(error)
        }
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

    func addNewTag(named tagName: String, to articleId: String) async -> Bool {
        do {
            var components = URLComponents(string: "https://getpocket.com/v3/send")!
            components.queryItems = [
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
                URLQueryItem(name: "actions", value: """
[{ "action": "tags_add", "item_id": "\(articleId)", "tags": "\(tagName)" }]
""")
            ]
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(ActionResponse.self, from: data)
            if response.actionResults.allSatisfy({ $0 }) {
                return true
            }
        } catch {
            print(error)
        }
        return false
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
