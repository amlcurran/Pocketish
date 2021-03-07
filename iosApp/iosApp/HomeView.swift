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

class Foo: ObservableObject {
    @Published var article: Article?
}

struct HomeView: View {

    @ObservedObject var viewModel: ObservableHomeViewModel
    @State var isDraggingArticle: Bool = false
    @State var showingArticle: Bool = false
    @StateObject var foo = Foo()

    private let selectedFeedback = UINotificationFeedbackGenerator()

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
        .sheet(isPresented: $showingArticle) {
            if let article = self.foo.article {
                SafariView(url: URL(string: article.url)!)
            } else {
                fatalError("No article to show")
            }
        }
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
        ZStack(alignment: .bottom) {
            ScrollView(.vertical) {
                HorizontalArticles(articles: state.latestUntagged, isDragging: $isDraggingArticle) {
                    viewModel.loadMoreUntagged()
                } onArticleClicked: { article in
                    foo.article = article
                    showingArticle = true
                }
                ForEach(state.tags) { (tag: Tag) in
                    tagListItem(from: tag)
                    if isDraggingArticle || tag.id != state.tags.last?.id {
                        Divider()
                    }
                }
                if isDraggingArticle {
                    ListItem(leftText: "Add new tag",
                        rightText: "",
                        leftColor: .accentColor,
                        rightImage: Image(systemName: "plus.circle"))
                }
            }
            Hidden(when: isDraggingArticle) {
                AnyView(Button("Foo") {
                    print("Clicked")
                }
                    .buttonStyle(RoundedButtonStyle())
                    .onDrop(of: ["public.text"], delegate: ArticleDropDelegate { articleId in
                        print("I'll add a new thing here")
                    })
                )
            }
        }.listStyle(PlainListStyle())
    }

    private func tagListItem(from tag: Tag) -> some View {
        NavigationLink(destination: ArticlesByTag(tag: tag)) {
            ListItem(leftText: tag.name,
                rightText: "\(tag.numberOfArticles)",
                rightImage: Image(systemName: "chevron.right"))
        }
            .onDrop(of: ["public.text"], delegate: ArticleDropDelegate { articleId in
                viewModel.add(tag, toArticleWithId: articleId) {
                    selectedFeedback.notificationOccurred(.success)
                }
            })
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

class ArticleDropDelegate: DropDelegate {

    private let droppedArticle: (String) -> Void
    private let dragOverFeedback = UISelectionFeedbackGenerator()

    init(droppedArticle: @escaping (String) -> ()) {
        self.droppedArticle = droppedArticle
    }

    func dropEntered(info: DropInfo) {
        dragOverFeedback.selectionChanged()
    }

    func performDrop(info: DropInfo) -> Bool {
        info.itemProviders(for: ["public.text"]).first?.loadItem(forTypeIdentifier: "public.text") { coding, error in
            if let data = coding as? Data, let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.droppedArticle(string)
                }
            }
        }
        return true
    }

}

class RoundedButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .makeTheButton(withColor: configuration.isPressed ? .accentColor : .green)
            .animation(.easeInOut(duration: 0.1))
    }

}

private extension View {

    func makeTheButton(withColor color: Color) -> some View {
        padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .frame(minWidth: 180)
            .foregroundColor(Color.white)
            .background(RoundedRectangle(cornerRadius: 24)
                .foregroundColor(color))
    }

}

struct Hidden: View {

    @State var when: Bool
    let content: () -> AnyView

    var body: some View {
        if when {
            print("XXX Hiding")
            return AnyView(content().hidden())
        } else {
            print("XXX Shown")
            return AnyView(content())
        }
    }

}