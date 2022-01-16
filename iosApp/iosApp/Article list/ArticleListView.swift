//
//  ArticleListView.swift
//  Pocketish
//
//  Created by Alex Curran on 16/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI
import shared

struct ArticleItemView: View {
    
    let article: Article
    
    var body: some View {
        Link(destination: URL(string: article.url)!) {
            HStack(alignment: .center) {
                RemoteImage(url: article.mainImage()?.src, showsSpinner: false)
                    .frame(width: 100, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title)
                        .font(.system(.body, design: .rounded))
                    Text(article.excerpt)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary)
            }
            .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
        .onDrag { NSItemProvider(object: article.id as NSString) }
    }
    
}
