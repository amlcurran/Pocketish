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
        print("Casting \(value.debugDescription) to \(T.self) resulting in \(value as? T)")
        callback(value as? T)
        completionHandler(KotlinUnit(), nil)
    }
}

class ObservableHomeViewModel: ObservableObject {
    private let homeViewModel: MainScreenViewModel

    @Published var state: AsyncResult<MainViewState> = AsyncResultLoading(foo: KotlinUnit())
    @Published var loadingMoreUntagged: Bool = false

    init(homeViewModel: MainScreenViewModel) {
        self.homeViewModel = homeViewModel
    }

    func appeared() {
        homeViewModel.state.collect { (value: AsyncResult<MainViewState>) in
            self.state = value
        }
        homeViewModel.getTagsState(ignoreCache: false) { state, error in

        }
    }

    func forceRefresh(onlyUntagged: Bool = false) async {
        do {
            try await homeViewModel.getTagsState(ignoreCache: true)
        } catch {
            print(error)
        }
    }

    func add(_ tag: Tag, toArticleWithId articleId: String, onFinished: @escaping () -> Void) {
        homeViewModel.addTagToArticle(tag: tag.id, articleId: articleId) { _, _ in

        }
    }

    func loadMoreUntagged() {
        loadingMoreUntagged = true
        homeViewModel.loadMoreUntagged { state, error in
            self.loadingMoreUntagged = false
        }
    }

    func duplicate() -> ObservableHomeViewModel {
        return ObservableHomeViewModel(homeViewModel: self.homeViewModel)
    }

    func archive(_ id: String, onFinished: @escaping () -> Void) {
        homeViewModel.archive(articleId: id) { _, _ in

        }
    }

    func addNewTag(named tagName: String, to articleId: String, onFinished: @escaping () -> Void) {
        homeViewModel.addTagToArticle(tag: tagName, articleId: articleId) { result, error in

        }
    }
    
    @Published var tagsState: AsyncResult<TagViewState> = AsyncResultLoading(foo: KotlinUnit())

    @MainActor
    func loadArticles(tagged tag: Tag) async {
        do {
            let result = try await homeViewModel.getArticlesWithTag(tag: tag.id)
            tagsState = AsyncResultSuccess(data: result)
        } catch {
            tagsState = AsyncResultError(error: error as! KotlinError)
        }
    }
}
