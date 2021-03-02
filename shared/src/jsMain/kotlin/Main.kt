import kotlinx.browser.document
import react.dom.render
import uk.co.amlcurran.pocketish.shared.App

fun main() {
    render(document.getElementById("root")) {
        child(App::class) {}
    }
}