package uk.co.amlcurran.pocketish.shared

fun <T> AsyncResult<T>.handle(onData: (T) -> Unit,
                              onLoading: () -> Unit,
                              onError: (Error) -> Unit = { }) {
    when (this) {
        is AsyncResult.Success -> onData(this.data)
        is AsyncResult.Loading -> onLoading()
        is AsyncResult.Error -> onError(this.error)
    }
}