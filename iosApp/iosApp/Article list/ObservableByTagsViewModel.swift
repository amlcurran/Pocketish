//
//  ObservableByTagViewModel.swift
//  Pocketish
//
//  Created by Alex Curran on 16/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import shared

struct TagViewState2 {
    let tag: Tag
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
}

class ObservableByTagsViewModel: ObservableObject {
    @Published var tagsState: AsyncResult2<TagViewState2> = .loading

    @MainActor
    func loadArticles(tagged tag: Tag) async {
        do {
            var components = URLComponents(string: "https://getpocket.com/v3/get")!
            components.queryItems = [
                URLQueryItem(name: "consumer_key", value: consumerKey),
                URLQueryItem(name: "access_token", value: UserDefaults.standard.string(forKey: "access_token")),
                URLQueryItem(name: "tag", value: tag.id),
                URLQueryItem(name: "detailType", value: "complete")
            ]
            let request = URLRequest(url: components.url!)
            let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(ApiListResponse.self, from: data)
            tagsState = .success(TagViewState2(tag: tag, articles: Array(response.list.values)))
        } catch {
            print(error)
            tagsState = .failure(error)
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
            let request = URLRequest(url: components.url!)
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

struct TagResponse: Decodable {
    let itemId: String
}

struct ArticleResponse: Decodable, Identifiable {
    let itemId: String
    let resolvedTitle: String
    let tags: [String: TagResponse]?
    let resolvedUrl: URL
    let excerpt: String
    let images: [String: Image]?
    
    struct Image: Decodable {
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
