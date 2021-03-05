import SwiftUI

struct ListItem: View {

    let leftText: String
    let rightText: String
    var leftColor: Color = .primary
    let rightImage: Image

    var body: some View {
        HStack {
            Text(leftText)
                .foregroundColor(leftColor)
            Spacer()
            Text(rightText)
                .foregroundColor(.secondary)
            rightImage
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(minHeight: 36)
    }

}
