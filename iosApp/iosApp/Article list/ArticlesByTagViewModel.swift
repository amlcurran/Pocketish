//
//  ObservableByTagViewModel.swift
//  Pocketish
//
//  Created by Alex Curran on 16/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import OrderedCollections

struct TagViewState2 {
    let tag: TagResponse
    let articles: [ArticleResponse]
}

enum AsyncResult2<Element> {
    case success(_ element: Element)
    case loading
    case failure(_ error: Error)
    
    var result: Element? {
        switch self {
        case .success(let result):
            return result
        default:
            return nil
        }
    }
    
    func map<NewElement>(_ mapper: (Element) -> NewElement) -> AsyncResult2<NewElement> {
        switch self {
        case .success(let input):
            return .success(mapper(input))
        case .loading:
            return .loading
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension AsyncResult2: Equatable where Element: Equatable {
    static func == (lhs: AsyncResult2<Element>, rhs: AsyncResult2<Element>) -> Bool {
        switch (lhs, rhs) {
        case (.success(let left), .success(let right)):
            return left == right
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
    
}

extension URLSession {
    
    func run<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
}

class ArticlesByTagViewModel: ObservableObject {
    @Published var tagsState: AsyncResult2<TagViewState2> = .loading

    @MainActor
    @discardableResult
    func loadArticles(tagged tag: TagResponse) async -> TagViewState2? {
        do {
            var components = URLComponents(string: "https://getpocket.com/v3/get")!
            components.queryItems = [
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
                URLQueryItem(name: "tag", value: tag.itemId),
                URLQueryItem(name: "sort", value: "oldest"),
                URLQueryItem(name: "detailType", value: "complete")
            ]
            let request = URLRequest(url: components.url!)
            let response = try await URLSession.shared.run(request, as: ApiListResponse.self)
            let viewState = TagViewState2(tag: tag, articles: response.list.map { $0.value })
            tagsState = .success(viewState)
            return viewState
        } catch {
            print(error)
            tagsState = .failure(error)
            return nil
        }
    }
    
    func articleWasArchived(_ articleId: String) {
        if let state = self.tagsState.result {
            self.tagsState = .success(
                TagViewState2(tag: state.tag, articles: state.articles.filter { $0.itemId != articleId })
            )
        }
    }
    
    func archive(_ id: String) async {
        do {
            var components = URLComponents(string: "https://getpocket.com/v3/send")!
            components.queryItems = [
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
                URLQueryItem(name: "actions", value: """
[{ "action": "archive", "item_id": "\(id)" }]
""")
            ]
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(ActionResponse.self, from: data)
            DispatchQueue.main.async {
                if response.actionResults.first == true, let state = self.tagsState.result {
                    self.tagsState = .success(
                        TagViewState2(tag: state.tag, articles: state.articles.filter { $0.itemId != id })
                    )
                }
            }
            
        } catch {
            
        }
    }
}

struct TagResponse: Equatable, Hashable, Identifiable, Decodable {
    let itemId: String
    
    static var untagged: TagResponse {
        TagResponse(itemId: "_untagged_")
    }
    
    var name: String {
        if itemId == TagResponse.untagged.itemId {
            return "Untagged"
        }
        return itemId
    }
    
    var id: String {
        itemId
    }
    
}

struct ArticleResponse: Equatable, Decodable, Identifiable {
    let itemId: String
    let resolvedTitle: String
    let tags: [String: TagResponse]?
    let resolvedUrl: URL
    let excerpt: String
    let images: [String: Image]?
    
    struct Image: Equatable, Decodable {
        let src: String
    }
    
    var id: String {
        itemId
    }
    
    var mainImage: Image? {
        images?.values.first
    }
}

struct ApiListResponse: Decodable {
    let list: [String: ArticleResponse]
}

struct ActionResponse: Decodable {
    let actionResults: [Bool]
}
