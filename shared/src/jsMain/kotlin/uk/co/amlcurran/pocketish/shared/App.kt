package uk.co.amlcurran.pocketish.shared

import kotlinx.browser.localStorage
import kotlinx.browser.window
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import react.RBuilder
import react.RComponent
import react.RProps
import react.RState
import react.dom.div

external interface LoginState : RState {
    var loading: Boolean
}

class App: RComponent<RProps, LoginState>() {

    override fun LoginState.init() {
        val scope = MainScope()
        scope.launch {
            print("Get ready")
            loginViewModel.login("https://www.google.com")
            setState(transformState = {
                it.loading = true
                return@setState it
            })
        }
    }

    private val loginViewModel = LoginViewModel(PocketApi(), object : URLLauncher {
        override fun launch(url: String) {
            window.open(url, target = "_blank")
        }

    }, object : UserStore {
        override fun get(key: String): String? {
            return localStorage.getItem(key)
        }

        override fun set(key: String, value: String?) {
            localStorage.setItem(key, value ?: "")
        }

        override fun getStringArray(key: String): Array<String> {
            return localStorage.getItem(key)?.split(";")?.toTypedArray() ?: emptyArray()
        }

        override fun setStringArray(key: String, list: List<String>) {
            localStorage.setItem(key, list.joinToString(","))
        }

    })

    override fun RBuilder.render() {
        div {
            +"Foo bar"
        }
    }

}