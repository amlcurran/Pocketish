import Foundation
import shared
import SwiftUI

class ObservableHomeViewModel: ObservableObject {
    private let homeViewModel: MainScreenViewModel

    @Published var state: AsyncResult<MainViewState> = .loading

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
        homeViewModel.getTagsState(ignoreCache: true) { state, error in
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
}

extension MainViewState {

    func tagging(_ articleId: String, with tag: Tag) -> MainViewState {
        doCopy(tags: tags, latestUntagged: latestUntagged.filter { $0.id != articleId })
    }

}