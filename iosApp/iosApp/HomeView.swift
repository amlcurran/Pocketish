//
//  TagsView.swift
//  iosApp
//
//  Created by Alex Curran on 23/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

enum AsyncResult<T: Equatable> {
    case idle
    case loading
    case failure(Error)
    case data(T)
}

struct HomeView: View {

    @ObservedObject var viewModel: ObservableHomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                viewForState(viewModel.state)
            }
            .navigationBarTitle("Tags")
            .toolbar {
                reloadButton()
            }
            .font(.system(.body, design: .rounded))
        }.onAppear { viewModel.appeared() }
    }

    private func reloadButton() -> some View {
        Button(action: {
            viewModel.forceRefresh()
        }) {
            if viewModel.reloading {
                ProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
    }

    private func viewForState(_ state: AsyncResult<MainViewState>) -> some View {
        switch state {
        case .loading, .idle, .failure:
            return AnyView(ProgressView())
        case .data(let state):
            return AnyView(MainView(state: state, viewModel: viewModel))
        }
    }

}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {

        }
//        HomeView(homeState: MainViewState(
//                    tags:  [
//                        Tag(id: "any", name: "Recipes", numberOfArticles: 4),
//                        Tag(id: "any1", name: "Long reads", numberOfArticles: 20),
//                        Tag(id: "any2", name: "Health", numberOfArticles: 1)
//                    ],
//                    latestUntagged: [
//                        Article(id: "abcd",
//                                title: "An article",
//                                tags: nil,
//                                url: "https://www.google.com", images: [:]),
//
//                        Article(id: "abcde",
//                                title: "Another article",
//                                tags: nil,
//                                url: "https://www.google.com", images: [:])
//                    ]), onRefreshClick: { })
    }
}