import UIKit
import SwiftUI
import shared

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISearchControllerDelegate {

    var window: UIWindow?
    let mainRouter = MainRouter()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(.rounded)!, size: 48)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withDesign(.rounded)!, size: 17)
        ]
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1).withDesign(.rounded)!, size: 17)
        ], for: .normal)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: LoadingYourTags())
            self.window = window
            mainRouter.start { [weak self] (shouldContinue, error) in
                if let shouldContinue = shouldContinue, shouldContinue.boolValue {
                    self?.display()
                }
            }
            window.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

    }

    private func display() {
        let api = PocketApi()
        let userStore = UserDefaultsStore()
        let repository = TagsFromArticlesRepository(pocketApi: api, userStore: userStore)
        let model = MainScreenViewModel(pocketApi: api, tagsRepository: repository, userStore: userStore)
        let viewModel = ObservableHomeViewModel(homeViewModel: model)
        let viewController = UIHostingController(rootView: HomeView(viewModel: viewModel).accentColor(.orange))
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        viewController.navigationItem.searchController = searchController
        viewController.navigationItem.largeTitleDisplayMode = .always
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for url in URLContexts where url.url.absoluteString == "pocketish:authorize" {
            mainRouter.continueLoggingIn { [weak self] _, _ in
                self?.display()
            }
        }
    }

}

