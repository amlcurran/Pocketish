import SwiftUI
import shared

struct ArticlesByTag: View {

    let tag: Tag

    var body: some View {
        Text(tag.name)
            .navigationTitle(tag.name)
            .navigationBarTitle(tag.name, displayMode: .inline)
    }

}