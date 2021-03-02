import SwiftUI
import shared

func greet() -> String {
    return Greeting().greeting()
}

struct LoadingYourTags: View {
    var body: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading your tags...")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingYourTags()
    }
}
