package uk.co.amlcurran.pocketish.shared

import kotlinx.browser.window
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.css.fontFamily
import kotlinx.html.js.onClickFunction
import react.*
import react.dom.button
import styled.css
import styled.styledDiv

external interface LoginState : RState {
    var loading: Boolean
    var loggedIn: Boolean
}

class App: RComponent<RProps, LoginState>(), URLLauncher {

    private val pocketApi = PocketApi()
    private val userStore = LocalStorageUserStore()
    private val loginViewModel = LoginViewModel(pocketApi, this, userStore)

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
            }
        }
    }

    override fun RBuilder.render() {
        styledDiv {
            css {
                fontFamily = "IBM Plex Sans, sans-serif"
            }
            if (state.loggedIn) {
                child(MainView::class) {
                    attrs.mainScreenViewModel = MainScreenViewModel(
                        pocketApi,
                        TagsFromArticlesRepository(pocketApi, userStore),
                        userStore
                    )
                }
            } else {
                button {
                    +"Log in to Pocket"
                    attrs {
                        onClickFunction = {
                            MainScope().launch {
                                loginViewModel.continueLogin()
                            }
                        }
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