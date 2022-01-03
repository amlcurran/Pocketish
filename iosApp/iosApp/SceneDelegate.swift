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

private func homeView() -> some View {
    let api = PocketApi()
    let userStore = UserDefaultsStore()
    let repository = TagsFromArticlesRepository(pocketApi: api, userStore: userStore)
    let model = MainScreenViewModel(pocketApi: api, tagsRepository: repository, userStore: userStore)
    let viewModel = ObservableHomeViewModel(homeViewModel: model)
    return HomeView(viewModel: viewModel)
        .accentColor(.orange)
}

@main
struct PocketishApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var loggedIn = false
    @State private var search = ""
    private let mainRouter = MainRouter()
    
    var body: some Scene {
        WindowGroup {
            if loggedIn {
                NavigationView {
                    homeView()
                }
                .searchable(text: $search, prompt: "Find an article")
                .navigationViewStyle(.stack)
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
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                mainRouter.start { (shouldContinue, error) in
                    loggedIn = shouldContinue?.boolValue ?? false
                }
            }
        }
    }
    
}
