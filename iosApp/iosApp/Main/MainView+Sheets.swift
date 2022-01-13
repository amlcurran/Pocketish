//
//  MainView+Sheets.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

struct Sheet: Identifiable {
    static func showArticle(_ article: Article) -> Sheet {
        Sheet(id: "article-" + article.id) { _ in
            AnyView(SafariView(url: URL(string: article.url)!))
        }
    }
    
    static func addNewTag(to article: String) -> Sheet {
        Sheet(id: "newtag-" + article) { mainView in
            AnyView(AddNewTagView { tagName in
                mainView.showSheet = nil
                mainView.viewModel.addNewTag(named: tagName, to: article) {
                    mainView.selectedFeedback.notificationOccurred(.success)
                }
            })
        }
    }
    
    let id: String
    let content: (MainView) -> AnyView
}
