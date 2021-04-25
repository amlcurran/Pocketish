package uk.co.amlcurran.pocketish.shared

import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import kotlinx.css.*
import kotlinx.css.properties.TextDecoration
import kotlinx.css.properties.s
import kotlinx.css.properties.transition
import react.*
import styled.*

external interface MainProps : RProps {
    var mainScreenViewModel: MainScreenViewModel
}

external interface MainState : RState {
    var viewState: AsyncResult<MainViewState>
}

class MainView: RComponent<MainProps, MainState>() {

    override fun RBuilder.render() {
        when (state.viewState) {
            is AsyncResult.Success -> foo(state.viewState.result!!)
            else -> +"Loading..."
        }
    }

    private fun RBuilder.foo(result: MainViewState) {
        styledDiv {
            css {
                display = Display.flex
                flexDirection = FlexDirection.row
                overflowX = Overflow.auto
                whiteSpace = WhiteSpace.nowrap
            }
            result.latestUntagged.map {
                article(it)
            }
        }
        result.tags.map {
            styledH3 {
                +it.name
            }
        }
    }

    override fun componentDidMount() {
        GlobalScope.launch {
            println("Setting up collection")
            MainScope().launch {
                props.mainScreenViewModel.state.collectLatest {
                    println("Collected $it")
                    setState {
                        viewState = it
                    }
                }
            }
            println("Loading state")
            props.mainScreenViewModel.getTagsState(false)
            println("Loaded state")
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


