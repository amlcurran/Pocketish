package uk.co.amlcurran.pocketish.shared

data class MainViewState(
    val tags: List<Tag>,
    val latestUntagged: List<Article>
)

class MainScreenViewModel(
    private val pocketApi: PocketApi,
    private val tagsRepository: TagsRepository,
    private val userStore: UserStore
) {

    suspend fun getTagsState(ignoreCache: Boolean): MainViewState {
        val tags = tagsRepository.allTags(ignoreCache = ignoreCache)
            .map { it to pocketApi.getArticlesWithTag(it, userStore["access_token"]!!) }
            .map { (tag, articles) ->
                Tag(tag, tag, articles.size)
            }
        val latestUntagged = pocketApi.getArticlesWithTag(
            "_untagged_",
            userStore["access_token"]!!,
            maxCount = 6,
            full = true
        )
        return MainViewState(tags, latestUntagged)
    }

    suspend fun addTagToArticle(tag: String, articleId: String): Boolean {
        return pocketApi.add(tagId = tag, articleId = articleId, userStore["access_token"]!!) ?: false
    }

}

data class Tag(
    val id: String,
    val name: String,
    val numberOfArticles: Int
)
