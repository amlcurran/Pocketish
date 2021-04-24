package uk.co.amlcurran.pocketish.shared

import kotlinx.coroutines.flow.MutableStateFlow

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

    val state = MutableStateFlow<AsyncResult<MainViewState>>(AsyncResult.Loading())

    suspend fun getTagsState(ignoreCache: Boolean) {
        state.value = AsyncResult.Loading()
        val tags = tagsRepository.allTags(ignoreCache = ignoreCache)
            .map { tag ->
                Tag(tag, tag, 0)
            }
        val latestUntagged = getLatestUntagged()
        val mainViewState = MainViewState(tags, latestUntagged)
        state.value = AsyncResult.Success(mainViewState)
    }

    private suspend fun getLatestUntagged(offset: Int = 0): List<Article> {
        return pocketApi.getArticlesWithTag(
            "_untagged_",
            userStore["access_token"]!!,
            maxCount = 10,
            offset = offset + 1,
            full = true
        )
    }

    suspend fun loadMoreUntagged() {
        val offset = state.value.result?.latestUntagged?.size ?: 0
        val extraUntagged = getLatestUntagged(offset)
        val oldUntagged = state.value.result?.latestUntagged ?: emptyList()
        state.value = AsyncResult.Success(state.value.result!!.copy(latestUntagged = oldUntagged + extraUntagged))
    }

    suspend fun getArticlesWithTag(tag: String): TagViewState {
        val latestUntagged = pocketApi.getArticlesWithTag(
            tag,
            userStore["access_token"]!!,
            offset = 0,
            full = true
        )
        return TagViewState(Tag(tag, tag, latestUntagged.size), latestUntagged)
    }

    suspend fun addTagToArticle(tag: String, articleId: String) {
        val add = pocketApi.add(tagId = tag, articleId = articleId, userStore["access_token"]!!) ?: false
        if (add) {
            state.value = AsyncResult.Success(state.value.result!!.tagging(articleId, tag))
        }
    }

    suspend fun archive(articleId: String) {
        val archived = pocketApi.archive(articleId, userStore["access_token"]!!) ?: false
        if (archived) {
            state.value = AsyncResult.Success(state.value.result!!.removingUntaggedArticle(articleId))
        }
    }

}

fun MainViewState.tagging(articleId: String, newTag: String): MainViewState {
    val tags = this.tags.toMutableList()
    val tag = Tag(newTag, newTag, 0)
    tags.add(tag)
    return copy(
        tags = tags,
        latestUntagged = latestUntagged.filter { it.id != articleId }
    )
}

fun MainViewState.removingUntaggedArticle(articleId: String): MainViewState {
    return copy(
        tags = tags,
        latestUntagged = latestUntagged.filter { it.id != articleId }
    )
}

data class Tag(
    val id: String,
    val name: String,
    val numberOfArticles: Int
)
