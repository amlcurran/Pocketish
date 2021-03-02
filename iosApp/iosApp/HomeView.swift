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

struct HomeView: View {

    let homeState: MainViewState
    let onRefreshClick: () -> Void

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
            .onDrop(of: ["public.text"], isTargeted: $foo, perform: { provider -> Bool in
                false
            })
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: HorizontalArticles(articles: homeState.latestUntagged)
                                .listRowInsets(EdgeInsets())) {
                        ForEach(homeState.tags, content: item)
                        NavigationLink(destination: AddTagView()) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .renderingMode(.template)
                                Text("Add new tag")
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                }.listStyle(PlainListStyle())
            }
            .navigationBarTitle("Tags")
            .toolbar {
                Button(action: onRefreshClick) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .font(.system(.body, design: .rounded))
        }
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
        HomeView(homeState: MainViewState(
                    tags:  [
                        Tag(id: "any", name: "Recipes", numberOfArticles: 4),
                        Tag(id: "any1", name: "Long reads", numberOfArticles: 20),
                        Tag(id: "any2", name: "Health", numberOfArticles: 1)
                    ],
                    latestUntagged: [
                        Article(id: "abcd",
                                title: "An article",
                                tags: nil,
                                url: "https://www.google.com", images: [:]),

                        Article(id: "abcde",
                                title: "Another article",
                                tags: nil,
                                url: "https://www.google.com", images: [:])
                    ]), onRefreshClick: { })
    }
}
