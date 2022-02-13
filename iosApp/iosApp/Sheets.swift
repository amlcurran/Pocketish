//
//  MainView+Sheets.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI

struct Sheet: Identifiable {
    static func showArticle(_ article: ArticleResponse) -> Sheet {
        Sheet(id: "article-" + article.id) { _ in
            AnyView(SafariView(url:article.resolvedUrl))
        }
    }
    
    static func addNewTag(to article: String) -> Sheet {
        Sheet(id: "newtag-" + article) { mainView in
            AnyView(
                NavigationView {
                    AddNewTagView { tagName in
                        mainView.showSheet = nil
                        Task {
                            let result = await mainView.viewModel.addNewTag(named: tagName, to: article)
                            if result {
                                await UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                        }
                    } content: { _ in
                        HStack {
                            
                        }
                    }
                }
            )
        }
    }
    
    static func addIcon(to tag: TagResponse) -> Sheet {
        Sheet(id: "add-icon-to-" + tag.id) { mainView in
            AnyView(
                NavigationView {
                    AddNewTagView { tagName in
                        mainView.showSheet = nil
                        NSUbiquitousKeyValueStore.default.set(tagName, forKey: "\(tag.id)-icon")
                        NotificationCenter.default.post(name: .didChangeIcon(of: tag), object: nil)
                    } content: { typedText in
                        VStack {
                            Image(systemName: typedText)
                        }
                            .font(.system(size: 36))
                            .frame(width: 40, height: 40)
                    }
                    .navigationTitle("Icon for \(tag.name)")
                    .navigationBarTitleDisplayMode(.inline)
                }
            )
        }
    }
    
    let id: String
    let content: (MainView) -> AnyView
}

extension NSNotification.Name {
    
    static func didChangeIcon(of tag: TagResponse) -> NSNotification.Name {
        NSNotification.Name(rawValue: "didChangeTagIcon\(tag.id)")
    }
    
}
