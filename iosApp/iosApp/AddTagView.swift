//
//  AddTagView.swift
//  iosApp
//
//  Created by Alex Curran on 27/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI
import shared

class ViewModelFoo: ObservableObject {

    @Published var completed: Bool = false

}

struct AddTagView: View {

    @State var tagName: String = ""

    var body: some View {
        VStack {
            TextField("Name", text: $tagName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Add") {

            }.padding()
            Spacer()
        }
        .navigationBarTitle("Add a new tag", displayMode: .inline)
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddTagView()
        }
    }
}
