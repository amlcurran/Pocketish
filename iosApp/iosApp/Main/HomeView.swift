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

enum AsyncResult<T: Equatable> {
    case idle
    case loading
    case failure(Error)
    case data(T)
}

enum OpenIn {
    case safari
    case inApp
}

struct HomeView: View {

    @ObservedObject var viewModel: ObservableHomeViewModel
    @State var launchType: OpenIn = .safari
    @StateObject var textObserver = TextFieldObserver()

    var body: some View {
        NavigationView {
            ZStack {
                viewForState(viewModel.state)
                    .animation(nil)
                if !textObserver.debouncedText.isEmpty {
                    Text(textObserver.debouncedText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.blue.opacity(0.2))
                }
            }
            .animation(Animation.easeIn.speed(4))
                .transition(.opacity)
            .navigationBarTitle("Tags")
            .toolbar {
                safariButton()
            }
            .font(.system(.body, design: .rounded))
        }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear { viewModel.appeared() }
    }

    private func searchOverlay() -> some View {
        if textObserver.debouncedText.isEmpty {
            return AnyView(Text("blahblah"))
        } else {
            return AnyView(Text(textObserver.debouncedText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .animation(.easeIn)
                            .transition(.opacity))
        }
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

    private func safariButton() -> some View {
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
            Image(systemName: "ellipsis.circle")
        }
    }

    private func viewForState(_ state: AsyncResult<MainViewState>) -> some View {
        switch state {
        case .loading, .idle, .failure:
            return AnyView(ProgressView())
        case .data(let state):
            return AnyView(MainView(state: state, searchText: $textObserver.searchText, viewModel: viewModel))
        }
    }

}

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""

    private var subscriptions = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { t in
                self.debouncedText = t
            } )
            .store(in: &subscriptions)
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