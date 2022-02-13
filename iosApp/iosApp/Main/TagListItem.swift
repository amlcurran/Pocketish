//
//  TagListItem.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI

struct TagListItem<Destination: View>: View {

    let tag: TagResponse
    @State var enteredTagDrop = false
    @State var linkIsActive = false
    @State var secretCounter = 0
    let onDropped: (String) -> Void
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination(), isActive: $linkIsActive) {
            Label(tag.name, systemImage: NSUbiquitousKeyValueStore.default.string(forKey: "\(tag.id)-icon") ?? "tag")
                .animation(.default.speed(4), value: secretCounter)
                .tint(enteredTagDrop ? .white : .accentColor)
        }
        .onTapGesture {
            linkIsActive = true
        }
        .onDrop(of: ["public.text"], delegate: ArticleDropDelegate(tag: tag, dropEntered: $enteredTagDrop) { articleId in
            onDropped(articleId)
        })
//        .background(HoverBackground(entered: $enteredTagDrop))
        .onReceive(NotificationCenter.default.publisher(for: .didChangeIcon(of: tag))) { _ in
            secretCounter += 1
        }
    }

}
