//
//  DropView.swift
//  Pocketish
//
//  Created by Alex Curran on 10/01/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import SwiftUI

struct DropView: View {
    
    @State var enteredArchiveDrop: Bool = false
    @State var dragClicked: Bool = false
    @State var enteredNewDrop: Bool = false
    @Binding var showSheet: Sheet?
    let onArticleDrop: (String) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button("Archive") {
                    dragClicked = true
                }
                .buttonStyle(RoundedButtonStyle(entered: $enteredArchiveDrop))
                .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredArchiveDrop, droppedArticle: { articleId in
                    onArticleDrop(articleId)
                }))
                Button("Add new tag") {
                    dragClicked = true
                }
                .buttonStyle(RoundedButtonStyle(entered: $enteredNewDrop))
                .onDrop(of: ["public.text"], delegate: ArticleDropDelegate2(dropEntered: $enteredNewDrop, droppedArticle: { articleId in
                    showSheet = .addNewTag(to: articleId)
                }))
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .alert(isPresented: $dragClicked) {
            Alert(title: Text("Add new tag"),
                  message: Text("Drag an article on the button to create a new tag"),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct DropView_Previews: PreviewProvider {
    static var previews: some View {
        DropView(showSheet: .constant(nil)) { _ in }
    }
}
