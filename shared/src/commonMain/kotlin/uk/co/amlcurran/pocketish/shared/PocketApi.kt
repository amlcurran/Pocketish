package uk.co.amlcurran.pocketish.shared

import io.ktor.client.*
import io.ktor.client.features.json.*
import io.ktor.client.features.json.serializer.*
import io.ktor.client.features.logging.*
import io.ktor.client.request.*
import io.ktor.http.*
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

class PocketApi {

    private val httpClient = HttpClient {
        install(Logging) {
            level = LogLevel.ALL
        }
        install(JsonFeature) {
            accept(ContentType.Any, ContentType.Application.Json)
            serializer = KotlinxSerializer(kotlinx.serialization.json.Json {
                ignoreUnknownKeys = true
            })
        }
    }

    private val consumerKey = "63449-1c93538d5080dc7b7e4a859a"

    suspend fun requestAccess(redirectUrl: Url): String {
        val response = httpClient.post<RequestResponse>("https://getpocket.com/v3/oauth/request") {
            contentType(ContentType.Application.Json)
            accept(ContentType.Application.Json)
            header("X-Accept", "application/json")
            body = RequestAuthBody(consumerKey, redirectUrl.toString().encodeURLParameter())
        }
        return response.code
    }

    @Serializable
    private data class RequestAuthBody(
        @SerialName("consumer_key") val appKey: String,
        @SerialName("redirect_uri") val redirectUri: String
    )

    @Serializable
    private data class RequestResponse(
        val code: String
    )

    suspend fun continueLogin(code: String): String {
        val response = httpClient.post<AuthorizeResponse>("https://getpocket.com/v3/oauth/authorize") {
            contentType(ContentType.Application.Json)
            accept(ContentType.Application.Json)
            header("X-Accept", "application/json")
            body = AuthorizeBody(consumerKey, code)
        }
        return response.accessToken
    }

    @Serializable
    data class AuthorizeBody(@SerialName("consumer_key") val consumerKey: String,
                             @SerialName("code") val code: String)

    @Serializable
    data class AuthorizeResponse(@SerialName("access_token") val accessToken: String)

    suspend fun getArticlesWithTag(tag: String, accessToken: String, maxCount: Int? = null, full: Boolean = false): List<Article> {
        return httpClient.get<ArticleListResponse>("https://getpocket.com/v3/get") {
            url.parameters["consumer_key"] = consumerKey
            url.parameters["access_token"] = accessToken
            url.parameters["tag"] = tag
            url.parameters["detailType"] = if (full) "complete" else "simple"
            maxCount?.let { url.parameters["count"] = "$it" }
        }.list.values.toList()
    }

    suspend fun allArticles(accessToken: String): List<Article> {
        return httpClient.get<ArticleListResponse>("https://getpocket.com/v3/get") {
            url.parameters["consumer_key"] = consumerKey
            url.parameters["access_token"] = accessToken
            url.parameters["detailType"] = "complete"
        }.list.values.toList()
    }
}

@Serializable
data class ArticleListResponse(
    val list: Map<String, Article>
)

@Serializable
data class Article(@SerialName("resolved_id") val id: String,
                   @SerialName("resolved_title") val title: String,
                   @SerialName("tags") val tags: Map<String, TagResponse>? = emptyMap(),
                   @SerialName("resolved_url" ) val url: String,
                   @SerialName("images") val images: Map<String, Image> = emptyMap()
) {

    @Serializable
    data class Image(
        val src: String
    )

    fun mainImage(): Image? {
        return images.values.firstOrNull()
    }

}

@Serializable
data class TagResponse(@SerialName("item_id") val itemId: String)

