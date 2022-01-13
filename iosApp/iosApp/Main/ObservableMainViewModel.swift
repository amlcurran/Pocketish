import Foundation
import shared
import SwiftUI

extension Tag: Identifiable {

}

extension Article: Identifiable {

}

extension Kotlinx_coroutines_coreMutableStateFlow {

    func collect<T>(_ collector: @escaping (T) -> Void) {
        self.collect(collector: Collector<T> {
            if let value = $0 {
                collector(value)
            }
        }) { _, _ in

        }
    }

}

class Collector<T>: Kotlinx_coroutines_coreFlowCollector {

    let callback: (T?) -> Void

    init(callback: @escaping (T?) -> Void) {
        self.callback = callback
    }


    func emit(value: Any?, completionHandler: @escaping (KotlinUnit?, Error?) -> Void) {
        callback(value as? T)
        completionHandler(KotlinUnit(), nil)
    }
}

class ObservableMainViewModel: ObservableObject {
    private let model: MainScreenViewModel

    @Published var state: AsyncResult<MainViewState> = AsyncResultLoading(foo: KotlinUnit())
    @Published var loadingMoreUntagged: Bool = false

    init(homeViewModel: MainScreenViewModel) {
        self.model = homeViewModel
        homeViewModel.state.collect { (value: AsyncResult<MainViewState>) in
            self.state = value
        }
    }

    func appeared() async throws {
        try await model.getTagsState(ignoreCache: false)
    }

    func forceRefresh(onlyUntagged: Bool = false) async {
        do {
            try await model.getTagsState(ignoreCache: true)
        } catch {
            print(error)
        }
    }

    func add(_ tag: Tag, toArticleWithId articleId: String, onFinished: @escaping () -> Void) {
        model.addTagToArticle(tag: tag.id, articleId: articleId) { result, _ in
            if result?.boolValue == true {
                NotificationCenter.default.post(name: .articleGotTagged, object: nil, userInfo: [
                    "articleId": articleId
                ])
            }
        }
    }

    func loadMoreUntagged() {
        loadingMoreUntagged = true
        model.loadMoreUntagged { state, error in
            self.loadingMoreUntagged = false
        }
    }

    func archive(_ id: String, onFinished: @escaping () -> Void) {
        model.archive(articleId: id) { _, _ in

        }
    }

    func addNewTag(named tagName: String, to articleId: String, onFinished: @escaping () -> Void) {
        model.addTagToArticle(tag: tagName, articleId: articleId) { result, error in
            
        }
    }
}

class ObservableByTagsViewModel: ObservableObject {
    private let model: MainScreenViewModel
    @Published var tagsState: AsyncResult<TagViewState> = AsyncResultLoading(foo: KotlinUnit())

    init(homeViewModel: MainScreenViewModel) {
        self.model = homeViewModel
    }

    @MainActor
    func loadArticles(tagged tag: Tag) async {
        do {
            let result = try await model.getArticlesWithTag(tag: tag.id)
            tagsState = AsyncResultSuccess(data: result)
        } catch {
            tagsState = AsyncResultError(error: error as! KotlinError)
        }
    }
    
    func articleWasArchived(_ articleId: String) {
        if let state = self.tagsState.result {
            self.tagsState = AsyncResultSuccess(
                data: TagViewState(tag: state.tag, articles: state.articles.filter { $0.id != articleId })
            )
        }
    }
    
    func archive(_ id: String) async {
        do {
            let result = try await model.archive(articleId: id)
            DispatchQueue.main.async {
                if result.boolValue, let state = self.tagsState.result {
                    self.tagsState = AsyncResultSuccess(
                        data: TagViewState(tag: state.tag, articles: state.articles.filter { $0.id != id })
                    )
                }
            }
            
        } catch {
            
        }
    }
}
