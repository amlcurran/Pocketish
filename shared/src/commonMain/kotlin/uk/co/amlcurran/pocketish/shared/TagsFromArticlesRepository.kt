package uk.co.amlcurran.pocketish.shared

class TagsFromArticlesRepository(
    private val pocketApi: PocketApi,
    private val userStore: UserStore
) : TagsRepository {

    override suspend fun allTags(ignoreCache: Boolean): List<String> {
        val storedTags = userStore.storedTags
        return if (storedTags.isEmpty() || ignoreCache) {
            println("Finding all tags")
            val accessToken = userStore["access_token"]!!
            val tagsFromApi = pocketApi.allArticles(accessToken)
                .flatMap { it.tags?.keys ?: emptyList() }
                .uniqueOnly()
            userStore.storedTags = tagsFromApi
            return tagsFromApi
        } else {
            println("Retrieving tags from cache")
            storedTags
        }
    }
}

private fun <T> List<T>.uniqueOnly(): List<T> {
   return toSet().toList()
}