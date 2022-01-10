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
    @State var enteredTagDrop: Tag?
    let onDropped: (String) -> Void
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            Text(tag.name)
        }
        .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(tag: tag, dropEntered: $enteredTagDrop) { articleId in
            onDropped(articleId)
        })
        .background(Color.accentColor.opacity(enteredTagDrop == tag ? 0.2 : 0))
        .animation(.default, value: enteredTagDrop)
    }

}
