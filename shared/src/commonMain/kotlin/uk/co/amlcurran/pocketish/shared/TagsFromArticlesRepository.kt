package uk.co.amlcurran.pocketish.shared

class TagsFromArticlesRepository(
    private val pocketApi: PocketApi,
    private val userStore: UserStore
) : TagsRepository {

    override suspend fun allTags(ignoreCache: Boolean): List<String> {
        println("allTags enter")
        val storedTags = userStore.storedTags
        println("got tags $storedTags")
        return if (storedTags.isEmpty() || ignoreCache) {
            println("Getting access token")
            val accessToken = userStore["access_token"]!!
            println("Got access token")
            val tagsFromApi = pocketApi.allArticles(accessToken)
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