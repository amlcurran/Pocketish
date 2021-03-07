package uk.co.amlcurran.pocketish.shared

interface UserStore {
    operator fun get(key: String): String?
    operator fun set(key: String, value: String?)

    fun getStringArray(key: String): Array<String>?
    fun setStringArray(key: String, list: List<String>)

    var storedTags: List<String>
        get() = getStringArray("tags")?.toList() ?: emptyList()
        set(value) = setStringArray("tags", value)

}
