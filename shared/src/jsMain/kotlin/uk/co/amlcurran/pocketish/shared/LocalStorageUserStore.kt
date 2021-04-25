package uk.co.amlcurran.pocketish.shared

import kotlinx.browser.localStorage

class LocalStorageUserStore: UserStore {

    override fun get(key: String): String? {
        return localStorage.getItem(key)
    }

    override fun set(key: String, value: String?) {
        localStorage.setItem(key, value ?: "")
    }

    override fun getStringArray(key: String): Array<String> {
        return localStorage.getItem(key)?.split(",")?.toTypedArray() ?: emptyArray()
    }

    override fun setStringArray(key: String, list: List<String>) {
        localStorage.setItem(key, list.joinToString(","))
    }
}