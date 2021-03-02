import UIKit
import SwiftUI
import shared

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

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
            let api = PocketApi()
            let userStore = UserDefaultsStore()
            let model = MainScreenViewModel(pocketApi: api, tagsRepository: TagsFromArticlesRepository(pocketApi: api, userStore: userStore), userStore: userStore)
            let viewController = UIHostingController(rootView: HomeView(viewModel: ObservableHomeViewModel(homeViewModel: model)))
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {

    }

    private func display(_ viewState: MainViewState) {
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for url in URLContexts {
            print(url.url.absoluteString)
            mainRouter.continueLoggingIn { [weak self] viewState, _ in
                if let viewState = viewState {
                    self?.display(viewState)
                }
            }
        }
    }

}

