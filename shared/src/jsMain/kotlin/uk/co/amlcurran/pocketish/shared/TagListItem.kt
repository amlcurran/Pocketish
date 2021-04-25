package uk.co.amlcurran.pocketish.shared

import react.RBuilder
import react.RComponent
import react.RProps
import react.RState
import react.dom.span
import styled.styledH3

class ListItemProps(
    var leftText: String
) : RProps

class ListItem: RComponent<ListItemProps, RState>() {

    override fun RBuilder.render() {
        styledH3 {
            +props.leftText
            span("material-icons") {
                +"chevron_right"
            }
        }
    }
}
