package uk.co.amlcurran.pocketish.shared

class TagsFromArticlesRepository(
    private val pocketApi: PocketApi,
    private val userStore: UserStore
) : TagsRepository {

    override suspend fun allTags(ignoreCache: Boolean): List<String> {
        val storedTags = userStore.storedTags
        return if (storedTags.isEmpty() || ignoreCache) {
            val tagsFromApi = pocketApi.allArticles(userStore["access_token"]!!)
                .flatMap { it.tags?.keys ?: emptyList() }
                .uniqueOnly()
            userStore.storedTags = tagsFromApi
            return tagsFromApi
        } else {
            storedTags
        }
    }
}

private fun <T> List<T>.uniqueOnly(): List<T> {
   return toSet().toList()
}