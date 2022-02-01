import UIKit
import SwiftUI
import shared

//class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISearchControllerDelegate {
//
//    var window: UIWindow?
//    let mainRouter = MainRouter()
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//
//        UINavigationBar.appearance().largeTitleTextAttributes = [
//            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(.rounded)!, size: 48)
//        ]
//        UINavigationBar.appearance().titleTextAttributes = [
//            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withDesign(.rounded)!, size: 17)
//        ]
//        UIBarButtonItem.appearance().setTitleTextAttributes([
//            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withDesign(.rounded)!, size: 17)
//        ], for: .normal)
//
//        // Use a UIHostingController as window root view controller.
//        if let windowScene = scene as? UIWindowScene {
//            let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = UIHostingController(rootView: LoadingYourTags())
//            self.window = window
//            mainRouter.start { [weak self] (shouldContinue, error) in
//                if let shouldContinue = shouldContinue, shouldContinue.boolValue {
//                    self?.display()
//                }
//            }
//            window.makeKeyAndVisible()
//        }
//    }
//
//    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
//
//    }
//
//    private func display() {
//        let viewController = UIHostingController(rootView: homeView())
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.delegate = self
//        viewController.navigationItem.searchController = searchController
//        viewController.navigationItem.largeTitleDisplayMode = .always
//        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.navigationBar.prefersLargeTitles = true
//        window?.rootViewController = navigationController
//    }
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        for url in URLContexts where url.url.absoluteString == "pocketish:authorize" {
//            mainRouter.continueLoggingIn { [weak self] _, _ in
//                self?.display()
//            }
//        }
//    }
//
//}


@main
struct PocketishApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var loggedIn = false
    private let mainRouter = MainRouter()
    
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
                                mainRouter.continueLoggingIn { _, _ in
                                    loggedIn = true
                                }
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
                mainRouter.start { (shouldContinue, error) in
                    loggedIn = shouldContinue?.boolValue ?? false
                }
            }
        }
    }
    
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
