//
//  TagsView.swift
//  iosApp
//
//  Created by Alex Curran on 23/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared
import Combine

struct InitialView: View {

    @StateObject var viewModel = ObservableMainViewModel(homeViewModel: .standard)

    var body: some View {
        AsyncView(state: viewModel.state) { state in
            MainView(state: state)
        }
        .animation(.easeIn.speed(4), value: viewModel.state)
        .navigationBarTitle("Tags")
        .font(.system(.body, design: .rounded))
        .navigationViewStyle(.stack)
        .task {
            do {
                try await viewModel.appeared()
            } catch {
                print(error)
            }
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
