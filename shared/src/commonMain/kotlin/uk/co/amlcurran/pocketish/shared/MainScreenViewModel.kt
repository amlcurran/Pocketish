package uk.co.amlcurran.pocketish.shared

data class MainViewState(
    val tags: List<Tag>,
    val latestUntagged: List<Article>
)

data class TagViewState(
    val tag: Tag,
    val articles: List<Article>
)

class MainScreenViewModel(
    private val pocketApi: PocketApi,
    private val tagsRepository: TagsRepository,
    private val userStore: UserStore
) {

    suspend fun getTagsState(ignoreCache: Boolean): MainViewState {
        val tags = tagsRepository.allTags(ignoreCache = ignoreCache)
            .map { tag ->
                Tag(tag, tag, 0)
            }
        val latestUntagged = pocketApi.getArticlesWithTag(
            "_untagged_",
            userStore["access_token"]!!,
            maxCount = 10,
            full = true
        )
        return MainViewState(tags, latestUntagged)
    }

    suspend fun getArticlesWithTag(tag: String): TagViewState {
        val latestUntagged = pocketApi.getArticlesWithTag(
            tag,
            userStore["access_token"]!!,
            full = true
        )
        return TagViewState(Tag(tag, tag, latestUntagged.size), latestUntagged)
    }

    suspend fun addTagToArticle(tag: String, articleId: String): Boolean {
        return pocketApi.add(tagId = tag, articleId = articleId, userStore["access_token"]!!) ?: false
    }

    suspend fun archive(articleId: String): Boolean {
        return pocketApi.archive(articleId, userStore["access_token"]!!) ?: false
    }

}

data class Tag(
    val id: String,
    val name: String,
    val numberOfArticles: Int
)
