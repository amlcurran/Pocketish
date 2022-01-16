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
                .frame(height: 100)
                .clipped()
            Text(article.definitelyTitle)
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

extension Article {

    var definitelyTitle: String {
        if title.isEmpty {
            return " "
        } else {
            return title
        }
    }

}
