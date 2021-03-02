package uk.co.amlcurran.pocketish.shared

import io.ktor.http.*
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext

val redirectUrl = "app://open.my.app"

class LoginViewModel(
    private val pocketApi: PocketApi,
    private val urlLauncher: URLLauncher,
    private val userStore: UserStore
) {

    fun needsLogin(): Boolean {
        return userStore["access_token"] == null
    }

    suspend fun start(launchingFresh: Boolean, continuing: suspend () -> Unit) {
        if (needsLogin()) {
            if (launchingFresh) {
                login(redirectUrl)
            } else {
                continueLogin()
                continuing()
            }
        } else {
            continuing()
        }
    }

    suspend fun login(redirectUrl: String) {
        userStore["code"] = pocketApi.requestAccess(Url(redirectUrl))
        urlLauncher.launch(
            "https://getpocket.com/auth/authorize?request_token=${userStore["code"]}&redirect_uri=${redirectUrl}"
        )
    }

    suspend fun continueLogin() {
        userStore["access_token"] = pocketApi.continueLogin(userStore["code"]!!)
        userStore["code"] = null
    }

}

interface URLLauncher {
    fun launch(url: String)
}
