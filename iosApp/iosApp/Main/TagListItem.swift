//
//  TagListItem.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

struct TagListItem<Destination: View>: View {

    let tag: Tag
    @Binding var enteredTagDrop: Tag?
    let onDropped: (String) -> Void
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            ListItem(leftText: tag.name,
                rightText: "\(tag.numberOfArticles)",
                rightImage: Image(systemName: "chevron.right"))
        }
        .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(tag: tag, dropEntered: $enteredTagDrop) { articleId in
            onDropped(articleId)
        })
        .background(enteredTagDrop == tag ? AnyView(Color.black.opacity(0.1).colorInvert()) : AnyView(Color.clear))
        .animation(.default)
    }

}
