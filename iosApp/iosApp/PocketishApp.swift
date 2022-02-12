import UIKit
import SwiftUI

@main
struct PocketishApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var loggedIn = false

    func performAuthRequest() async throws {
        var request = URLRequest(url: URL(string: "https://getpocket.com/v3/oauth/request")!)
        request.httpMethod = "POST"
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(RequestAuthBody(
            consumerKey: consumerKey,
            redirectUri: "pocketish:authorize"
        ))
        do {
            let code = try await URLSession.shared.run(request, as: AuthResponse.self)
            UserDefaults.standard.set(code, forKey: "code")
        } catch {
            print(error)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if loggedIn {
                    NavigationView {
                        InitialView()
//                        ArticlesByTag(tag: Tag.companion.untagged)
                    }
                } else {
                    LoadingYourTags()
                        .onOpenURL { url in
                            if url.absoluteString == "pocketish:authorize" {
//                                mainRouter.continueLoggingIn { _, _ in
//                                    loggedIn = true
//                                }
                            }
                        }
                }
            }
            .animation(.default, value: loggedIn)
            .accentColor(Color("Color"))
            .environment(\.openIn, .safari)
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                Task {
                    if UserDefaults.standard.string(forKey: "access_token") == nil {
                        try await performAuthRequest()
                    } else {
                        loggedIn = true
                    }
                }
            }
        }
    }
    
}

struct RequestAuthBody: Encodable {
    let consumerKey: String
    let redirectUri: String
}

struct AuthResponse: Decodable {
    let code: String
}

extension Color {
    
    static var onAccent: Color {
        Color(uiColor: UIColor(dynamicProvider: { traits in
            if traits.userInterfaceStyle == .dark {
                return .black
            } else {
                return .white
            }
        }))
    }
    
}

struct OpenInEnvironmentKey: EnvironmentKey {
    typealias Value = OpenIn
    
    static let defaultValue: OpenIn = .safari
}

extension EnvironmentValues {
    var openIn: OpenIn {
        get { self[OpenInEnvironmentKey.self] }
        set { self[OpenInEnvironmentKey.self] = newValue }
    }
}
