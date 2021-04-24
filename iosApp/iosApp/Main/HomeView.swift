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

enum OpenIn: Int {
    case safari
    case inApp
}

struct HomeView: View {

    @ObservedObject var viewModel: ObservableHomeViewModel
    @AppStorage("launchType") var launchType: OpenIn = .safari
    @StateObject var textObserver = Debouncer<String>(initial: "")

    var body: some View {
            ZStack {
                AsyncView(state: viewModel.state) { state in
                    MainView(state: state, searchText: $textObserver.searchText, viewModel: viewModel)
                }.animation(nil)
            }
            .animation(Animation.easeIn.speed(4))
                .transition(.opacity)
            .navigationBarTitle("Tags")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button(action: {
                            viewModel.forceRefresh()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        .disabled(viewModel.reloading)
                        Picker(selection: $launchType, label: Text("FOO")) {
                            Label("Open in browser", systemImage: "safari")
                                .tag(OpenIn.safari)
                            Label("Open in app", systemImage: "app.badge")
                                .tag(OpenIn.inApp)
                        }
                    }
                    label: {
                        Label("", systemImage: "ellipsis.circle")
                    }
                }
            }
            .font(.system(.body, design: .rounded))
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear { viewModel.appeared() }
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
