//
//  ArticleListView.swift
//  Pocketish
//
//  Created by Alex Curran on 16/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI

struct ArticleItemView: View {
    
    let article: ArticleResponse
    
    var body: some View {
        Link(destination: article.resolvedUrl) {
            HStack(alignment: .center) {
                RemoteImage(url: article.mainImage?.src, showsSpinner: false)
                    .frame(width: 100, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.resolvedTitle)
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
        .onDrag {
            NSItemProvider(object: article.itemId as NSString)
        }
    }
    
}
