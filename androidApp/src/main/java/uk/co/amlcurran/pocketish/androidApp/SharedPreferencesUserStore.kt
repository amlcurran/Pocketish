package uk.co.amlcurran.pocketish.androidApp

import android.content.Context
import uk.co.amlcurran.pocketish.shared.UserStore

class SharedPreferencesUserStore(private val context: Context) : UserStore {
    override fun get(key: String): String? {
        return context.getSharedPreferences("login", Context.MODE_PRIVATE).getString(key, null)
    }

    override fun set(key: String, value: String?) {
        context.getSharedPreferences("login", Context.MODE_PRIVATE)
            .edit()
            .putString(key, value)
            .apply()
    }

    override fun getStringArray(key: String): Array<String> {
        return context.getSharedPreferences("foo", Context.MODE_PRIVATE)
            .getStringSet(key, emptySet())
            ?.toTypedArray() ?: emptyArray()
    }

    override fun setStringArray(key: String, list: List<String>) {
        context.getSharedPreferences("login", Context.MODE_PRIVATE)
            .edit()
            .putStringSet(key, list.toSet())
            .apply()
    }

}