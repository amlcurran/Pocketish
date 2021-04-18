package uk.co.amlcurran.pocketish.shared

import kotlinx.css.*
import kotlinx.css.properties.TextDecoration
import kotlinx.css.properties.Time
import kotlinx.css.properties.s
import kotlinx.css.properties.transition
import react.RBuilder
import react.RComponent
import react.RProps
import react.RState
import styled.*
import kotlin.time.seconds

external interface MainProps : RProps {
    var mainState: MainViewState
}

class MainView: RComponent<MainProps, RState>() {

    override fun RBuilder.render() {
        styledDiv {
            css {
                display = Display.flex
                flexDirection = FlexDirection.row
                overflowX = Overflow.auto
                whiteSpace = WhiteSpace.nowrap
            }
            props.mainState.latestUntagged.map {
                article(it)
            }
        }
        props.mainState.tags.map {
            styledH3 {
                +it.name
            }
        }
    }
}

fun RBuilder.article(article: Article) {
    styledA(href = article.url, target = "_blank") {
        css {
            flex(flexGrow = 0.0, flexShrink = 0.0, flexBasis = 200.px.basis)
            overflowX = Overflow.initial
            whiteSpace = WhiteSpace.initial
            padding(all = 16.px)
            color = Color.inherit
            textDecoration = TextDecoration.none
            borderRadius = 16.px
            transition("background-color", duration = 0.1.s)
            hover {
                backgroundColor = Color.bisque
            }
        }
        styledDiv {
            css {
                height = 150.px
                width = 100.pct
                backgroundColor = Color.aliceBlue
                borderRadius = 16.px
            }
            article.mainImage()?.src?.let { src ->
                styledImg(src = src) {
                    css {
                        height = 100.pct
                        width = 100.pct
                        objectFit = ObjectFit.cover
                        borderRadius = 16.px
                    }
                }
            }
        }
        styledH4 {
            css {
                margin(vertical = 0.8.em)
            }
            +article.title
        }
        +article.excerpt
    }
}

fun <T> T?.orElse(generator: () -> T): T {
    return this ?: generator()
}


