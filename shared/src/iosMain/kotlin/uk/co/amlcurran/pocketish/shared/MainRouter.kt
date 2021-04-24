package uk.co.amlcurran.pocketish.shared

import platform.Foundation.NSURL
import platform.Foundation.NSUserDefaults
import platform.UIKit.UIApplication

class MainRouter {

    private val pocketApi = PocketApi()
    private val userStore = UserDefaultsStore()
    private val loginViewModel by lazy {
        LoginViewModel(pocketApi, object : URLLauncher {
            override fun launch(url: String) {
                UIApplication.sharedApplication.openURL(NSURL(string = url))
            }
        }, userStore)
    }

    suspend fun start(): Boolean {
        if (loginViewModel.needsLogin()) {
            loginViewModel.login("pocketish:authorize")
            return false
        }
        return true
    }

    suspend fun continueLoggingIn() {
        loginViewModel.continueLogin()
    }

}

class UserDefaultsStore : UserStore {
    override fun get(key: String): String? {
        return NSUserDefaults.standardUserDefaults.stringForKey(key)
    }

    override fun set(key: String, value: String?) {
        NSUserDefaults.standardUserDefaults.setObject(value, key)
    }

    override fun getStringArray(key: String): Array<String> {
        val stringArrayForKey = NSUserDefaults.standardUserDefaults.stringArrayForKey(key) as? List<String>?
        return stringArrayForKey?.toTypedArray() ?: emptyArray()
    }

    override fun setStringArray(key: String, list: List<String>) {
        NSUserDefaults.standardUserDefaults.setObject(list, key)
    }

}