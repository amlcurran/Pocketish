import UIKit
import SwiftUI

@main
struct PocketishApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSize: UserInterfaceSizeClass?
    @ObservedObject private var loginViewModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if loginViewModel.loggedIn {
                    NavigationView {
                        InitialView(horizontalSize: .regular)
                        ArticlesByTag(tag: .untagged)
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
            .background {
                WindowView { window in
#if targetEnvironment(macCatalyst)
                    if let titlebar = window.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbarStyle = .expanded
//                        titlebar.toolbar = nil
                    }
#endif
                }
            }
            .animation(.default, value: loginViewModel.loggedIn)
            .accentColor(Color("Color"))
            .environment(\.openIn, .safari)
            .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)) { _ in
                NSUbiquitousKeyValueStore.default.synchronize()
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                Task {
                    try await loginViewModel.login()
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

struct WindowView: UIViewRepresentable {
    
    let window: (UIWindow) -> Void
    
    func makeUIView(context: Context) -> some UIView {
        Foo(callback: window)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    
}

class Foo: UIView {
    
    let callback: (UIWindow) -> Void
    
    init(callback: @escaping (UIWindow) -> Void) {
        self.callback = callback
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let newWindow = newWindow {
            callback(newWindow)
        }
    }
}
