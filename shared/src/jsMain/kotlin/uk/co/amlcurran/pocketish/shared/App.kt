package uk.co.amlcurran.pocketish.shared

import kotlinx.browser.localStorage
import kotlinx.browser.window
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.html.js.onClickFunction
import react.*
import react.dom.button
import react.dom.div
import kotlin.js.Console

external interface LoginState : RState {
    var loading: Boolean
    var loggedIn: Boolean
    var mainState: MainViewState?
}


class App: RComponent<RProps, LoginState>(), URLLauncher {

    private val pocketApi = PocketApi()
    private val userStore = LocalStorageUserStore()
    private val loginViewModel = LoginViewModel(pocketApi, this, userStore)
    private val mainViewModel = MainScreenViewModel(pocketApi, TagsFromArticlesRepository(pocketApi, userStore), userStore)

    override fun LoginState.init() {
        MainScope().launch {
            if (loginViewModel.needsLogin()) {
                loginViewModel.login("https://www.google.com")
                setState {
                    loading = true
                }
            } else {
                setState {
                    loggedIn = true
                }
                val state = mainViewModel.getTagsState(ignoreCache = false)
                setState {
                    mainState = state
                }
            }
        }
    }

    override fun RBuilder.render() {
        state.mainState?.let {
            div {
                +"${it.latestUntagged.size}"
            }
        }
        button {
            +"Authorize"
            attrs {
                onClickFunction = {
                    MainScope().launch {
                        loginViewModel.continueLogin()
                    }
                }
            }
        }
    }

    override fun launch(url: String) {
        console.log("Launching $url")
        window.open(url)
    }

}