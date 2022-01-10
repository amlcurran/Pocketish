//
//  HorizontalArticles.swift
//  iosApp
//
//  Created by Alex Curran on 27/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

extension Optional {

    func getOrThrow() throws -> Wrapped {
        if let self = self {
            return self
        } else {
            throw NSError(domain: "getOrThrow", code: 0)
        }
    }

}

struct HorizontalArticles: View {

    let articles: [Article]
    @Binding var loadingMore: Bool
    let onEndClicked: () -> Void
    let onArticleClicked: (Article) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(articles) { article in
                    ArticleView(article: article)
                        .frame(width: 200)
                        .modifier(.card)
                        .onDrag { NSItemProvider(object: article.id as NSString) }
                        .onTapGesture { onArticleClicked(article) }
                }.animation(.easeInOut(duration: 0.2), value: articles)
                ZStack {
                    Image(systemName: "chevron.forward.circle.fill")
                        .font(.system(size: 42))
                        .padding()
                        .onTapGesture { onEndClicked() }
                        .disabled(loadingMore)
                        .opacity(loadingMore ? 0 : 1)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .opacity(loadingMore ? 1 : 0)
                }.animation(.default, value: loadingMore)
            }
            .padding(.foo([.bottom]))
        }
    }
}

//struct HorizontalArticles_Previews: PreviewProvider {
//
//    static var previews: some View {
//        HorizontalArticles(articles: [
//            Article(id: "abcd",
//                    title: "An article",
//                    tags: nil,
//                    url: "https://www.google.com", images: [:]),
//            Article(id: "abcde",
//                    title: "Another article",
//                    tags: nil,
//                    url: "https://www.google.com", images: [:])
//        ], isDragging: false) {
//            //
//        }
//    }
//}
