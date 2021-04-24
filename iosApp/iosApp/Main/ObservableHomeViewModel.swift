import Foundation
import shared
import SwiftUI

extension Tag: Identifiable {

}

extension Article: Identifiable {

}

class ObservableHomeViewModel: ObservableObject {
    private let homeViewModel: MainScreenViewModel

    @Published var state: AsyncResult<MainViewState> = .loading
    @Published var tagsState: AsyncResult<TagViewState> = .loading
    @Published var reloading: Bool = false
    @Published var loadingMoreUntagged: Bool = false

    init(homeViewModel: MainScreenViewModel) {
        self.homeViewModel = homeViewModel
    }

    func appeared() {
        homeViewModel.getTagsState(ignoreCache: false) { state, error in
            if let state = state {
                self.state = .data(state)
            }
            if let error = error {
                self.state = .failure(error)
            }
        }
    }

    func forceRefresh(onlyUntagged: Bool = false) {
        reloading = true
        homeViewModel.getTagsState(ignoreCache: true) { state, error in
            self.reloading = false
            if let state = state {
                self.state = .data(state)
            }
            if let error = error {
                self.state = .failure(error)
            }
        }
    }

    func add(_ tag: Tag, toArticleWithId articleId: String, onFinished: @escaping () -> Void) {
        homeViewModel.addTagToArticle(tag: tag.id, articleId: articleId) { [self] result, error in
            if let error = error {
                print(error)
            } else {
                if let result = result, result == KotlinBoolean(bool: true) {
                    if case AsyncResult<MainViewState>.data(let current) = state {
                        state = .data(current.removingUntaggedArticle(articleId))
                    }
                    onFinished()
                }
            }
        }
    }

    func loadMoreUntagged() {
        loadingMoreUntagged = true
        let offset = state.value?.latestUntagged.count ?? 0
        homeViewModel.getLatestUntagged(offset: Int32(offset)) { state, error in
            self.loadingMoreUntagged = false
            if let state = state, case let .data(data) = self.state {
                var newArticles = data.latestUntagged
                newArticles.append(contentsOf: state)
                self.state = .data(data.doCopy(tags: data.tags, latestUntagged: newArticles))
            }
            if let error = error {
                self.state = .failure(error)
            }
        }
    }

    func duplicate() -> ObservableHomeViewModel {
        return ObservableHomeViewModel(homeViewModel: self.homeViewModel)
    }

    func archive(_ id: String, onFinished: @escaping () -> Void) {
        homeViewModel.archive(articleId: id) { [self] result, error in
            if let error = error {
                print(error)
            } else {
                if let result = result, result == KotlinBoolean(bool: true) {
                    if case AsyncResult<MainViewState>.data(let current) = state {
                        state = .data(current.removingUntaggedArticle(id))
                    }
                    onFinished()
                }
            }
        }
    }

    func addNewTag(named tagName: String, to articleId: String, onFinished: @escaping () -> Void) {
        homeViewModel.addTagToArticle(tag: tagName, articleId: articleId) { [self] result, error in
            if let error = error {
                print(error)
            } else {
                if let result = result, result == KotlinBoolean(bool: true) {
                    if case AsyncResult<MainViewState>.data(let current) = state {
                        state = .data(current.tagging(articleId, withNewTag: tagName))
                    }
                    onFinished()
                }
            }
        }
    }

    func loadArticles(tagged tag: Tag) {
        homeViewModel.getArticlesWithTag(tag: tag.id) { [weak self] result, error in
            if let error = error {
                print(error)
            } else {
                if let result = result {
                    self?.tagsState = .data(result)
                }
            }
        }
    }
}

extension MainViewState {

    func removingUntaggedArticle(_ articleId: String) -> MainViewState {
        doCopy(tags: tags, latestUntagged: latestUntagged.filter { $0.id != articleId })
    }

    func tagging(_ articleId: String, withNewTag newTag: String) -> MainViewState {
        var tags: [Tag] = self.tags
        let tag = Tag(id: newTag, name: newTag, numberOfArticles: 0)
        tags.append(tag as Tag)
        return doCopy(tags: tags, latestUntagged: latestUntagged.filter { $0.id != articleId })
    }

}
