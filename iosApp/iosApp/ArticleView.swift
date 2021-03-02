//
//  ArticleView.swift
//  iosApp
//
//  Created by Alex Curran on 27/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

struct ArticleView: View {

    let article: Article

    var body: some View {
        VStack {
            RemoteImage(url: article.mainImage()?.src)
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: 90)
            Text(article.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .padding(.foo([.leading, .trailing, .top]))
                .textCase(.none)
            Text(article.url)
                .lineLimit(1)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.foo([.leading, .trailing, .bottom]))
                .font(.caption)
                .textCase(.none)
        }
    }
}

struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(article: Article(id: "abcde",
                                     title: "Another article",
                                     tags: nil,
                                     url: "https://www.google.com", images: [:]))
    }
}
