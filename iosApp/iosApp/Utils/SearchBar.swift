//
//  SearchBar.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI

struct SearchBar: View {

    let placeholder: String
    @Binding var searchText: String
    @State var isEditing = false

        var body: some View {
            HStack {
                TextField(placeholder, text: $searchText)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8).overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)

                            if isEditing {
                                Button(action: {
                                    self.searchText = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        self.isEditing = true
                    }

                if isEditing {
                    Button(action: {
                        self.isEditing = false
                        self.searchText = ""

                    }) {
                        Text("Cancel")
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
        }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SearchBar(placeholder: "Search", searchText: .constant(""))
            SearchBar(placeholder: "Find sexy stuff", searchText: .constant(""), isEditing: true)
        }
    }
}
