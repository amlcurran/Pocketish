import SwiftUI
import shared

struct UntaggedView: View {
    
    let latestUntagged: [Article]
    let compact: Bool
    @Binding var loadingMoreUntagged: Bool
    let onLoadMore: () -> Void
    @Environment(\.openURL) var openURL: OpenURLAction
    
    var body: some View {
        if compact {
            HorizontalArticles(articles: latestUntagged,
                               loadingMore: $loadingMoreUntagged,
                               onEndClicked: onLoadMore) { article in
                openURL(URL(string: article.url)!)
            }
        } else {
            NavigationLink("Untagged") {
                ArticlesByTag(tag: Tag.companion.untagged)
            }
        }
    }
    
}
