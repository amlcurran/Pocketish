//
//  TagsView.swift
//  iosApp
//
//  Created by Alex Curran on 23/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

struct Padding {
    let value: CGFloat

    static let half = Padding(value: 4)
    static let full = Padding(value: 12)
    static let large = Padding(value: 12)
}

extension EdgeInsets {

    static func foo(_ set: [NSDirectionalRectEdge]) -> EdgeInsets {
        var insets = EdgeInsets()
        if set.contains(.leading) {
            insets.leading = Padding.full.value
        }
        if set.contains(.top) {
            insets.top = Padding.full.value
        }
        if set.contains(.trailing) {
            insets.trailing = Padding.full.value
        }
        if set.contains(.bottom) {
            insets.bottom = Padding.full.value
        }
        return insets
    }

}

enum AsyncResult<T: Equatable> {
    case idle
    case loading
    case failure(Error)
    case data(T)
}

struct HomeView: View {

    @ObservedObject var viewModel: ObservableHomeViewModel

    @State var foo: Bool = false

    private func item(from tag: Tag) -> some View {
        NavigationLink(destination: ArticlesByTag(tag: tag)) {
            HStack {
                Text(tag.name)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(tag.numberOfArticles)")
                    .foregroundColor(.secondary)
            }
        }
            .frame(minHeight: 44)
            .onDrop(of: ["public.text"], isTargeted: $foo) { (providers: [NSItemProvider]) -> Bool in
                providers.forEach {
                    $0.loadItem(forTypeIdentifier: "public.text") { coding, error in
                        if let data = coding as? Data, let string = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                viewModel.add(tag, toArticleWithId: string)
                            }
                        }
                    }
                }
                return true
            }
    }

    var body: some View {
        NavigationView {
            VStack {
                viewForState(viewModel.state)
            }
            .navigationBarTitle("Tags")
            .toolbar {
                Button(action: {
                    viewModel.forceRefresh()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .font(.system(.body, design: .rounded))
        }.onAppear { viewModel.appeared() }
    }

    private func viewForState(_ state: AsyncResult<MainViewState>) -> some View {
        switch state {
        case .loading, .idle, .failure:
            return AnyView(ProgressView())
        case .data(let state):
            return AnyView(loadedView(forState: state))
        }
    }

    private func loadedView(forState state: MainViewState) -> some View {
        VStack {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged)
                ForEach(state.tags) { (tag: Tag) in
                    item(from: tag)
                }
            }
        }.listStyle(PlainListStyle())
    }

}

struct ArticlesByTag: View {

    let tag: Tag

    var body: some View {
        Text(tag.name)
            .navigationTitle(tag.name)
            .navigationBarTitle(tag.name, displayMode: .inline)
    }

}

extension Tag: Identifiable {

}

extension Article: Identifiable {

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
