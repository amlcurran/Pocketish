//
//  ObservableByTagViewModel.swift
//  Pocketish
//
//  Created by Alex Curran on 16/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import shared

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
