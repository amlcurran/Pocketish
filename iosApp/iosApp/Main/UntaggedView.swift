import SwiftUI

struct UntaggedView: View {
    
    let latestUntagged: [ArticleResponse]
    let compact: Bool
    @Binding var loadingMoreUntagged: Bool
    let onLoadMore: () -> Void
    @Environment(\.openURL) var openURL: OpenURLAction
    
    var body: some View {
        if compact {
            HorizontalArticles(articles: latestUntagged,
                               loadingMore: $loadingMoreUntagged,
                               onEndClicked: onLoadMore) { article in
                openURL(article.resolvedUrl)
            }
        } else {
            NavigationLink("Untagged") {
                ArticlesByTag(tag: .untagged)
            }
        }
    }
    
}
