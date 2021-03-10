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

    func forceRefresh() {
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
                        state = .data(current.tagging(articleId, with: tag))
                    }
                    onFinished()
                }
            }
        }
    }

    func loadMoreUntagged() {
        print("No-op for now!")
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

    func tagging(_ articleId: String, with tag: Tag) -> MainViewState {
        doCopy(tags: tags, latestUntagged: latestUntagged.filter { $0.id != articleId })
    }

    func tagging(_ articleId: String, withNewTag newTag: String) -> MainViewState {
        var tags: [Tag] = self.tags
        let tag = Tag(id: newTag, name: newTag, numberOfArticles: 0)
        tags.append(tag as Tag)
        return doCopy(tags: tags, latestUntagged: latestUntagged.filter { $0.id != articleId })
    }

}
