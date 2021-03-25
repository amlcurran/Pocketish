import SwiftUI

struct RoundedButtonStyle: ButtonStyle {

    @Binding var entered: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .makeTheButton(withColor: entered ? Color.accentColor : .accentColor)
            .animation(.easeInOut(duration: 0.1))
    }

}

private extension View {

    func makeTheButton(withColor color: Color) -> some View {
        padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .frame(minWidth: 180)
            .foregroundColor(Color.white)
            .background(RoundedRectangle(cornerRadius: 24)
                .foregroundColor(color))
    }

}
