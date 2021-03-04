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

    func add(_ tag: Tag, toArticleWithId articleId: String) {
        homeViewModel.addTagToArticle(tag: tag.id, articleId: articleId) { [self] result, error in
            if let error = error {
                print(error)
            } else {
                if let result = result, result == KotlinBoolean(bool: true),
                   case AsyncResult<MainViewState>.data(let current) = state {
                    state = .data(current.doCopy(tags: current.tags, latestUntagged: current.latestUntagged.filter { $0.id != articleId }))
                }
            }
        }
    }
}