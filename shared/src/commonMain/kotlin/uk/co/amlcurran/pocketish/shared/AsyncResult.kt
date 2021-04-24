package uk.co.amlcurran.pocketish.shared

sealed class AsyncResult<T> {
    data class Success<T>(val data: T): AsyncResult<T>()
    data class Loading<T>(val foo: Unit = Unit): AsyncResult<T>()
    data class Error<T>(val error: kotlin.Error): AsyncResult<T>()

    val result: T? get() = when (this) {
        is Success -> this.data
        is Loading -> null
        is Error -> null
    }
}