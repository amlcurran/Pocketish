import SwiftUI

struct RoundedButtonStyle: ButtonStyle {

    @Binding var entered: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 24).foregroundColor(.accentColor))
            .brightness(entered ? -0.2 : 0.0)
            .animation(.easeInOut(duration: 0.1))
    }

}
