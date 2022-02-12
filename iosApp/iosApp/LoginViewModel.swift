//
//  LoginView.swift
//  Pocketish
//
//  Created by Alex Curran on 12/02/2022.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation

class LoginViewModel: ObservableObject {
    
    @Published var loggedIn = false
    
    func login() async throws {
        if UserDefaults.standard.string(forKey: "access_token") == nil {
            try await performAuthRequest()
        } else {
            loggedIn = true
        }
    }
    
    private func performAuthRequest() async throws {
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
    
}
