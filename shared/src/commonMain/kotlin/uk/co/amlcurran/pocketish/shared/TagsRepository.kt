package uk.co.amlcurran.pocketish.shared

interface TagsRepository {
    suspend fun allTags(ignoreCache: Boolean): List<String>
}
