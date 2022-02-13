//
//  RemoteImage.swift
//  iosApp
//
//  Created by Alex Curran on 27/02/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import SwiftUI

enum LoadState<T> {
    case loading, success(T), failure
}

extension LoadState: Equatable where T: Equatable {
    
}

private class RemoteLoader: ObservableObject {
    @Published var state = LoadState<UIImage>.loading

    init(url: String?) {
        if let foo = url, let parsedURL = URL(string: foo) {
            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.state = .success(image)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.state = .failure
                        }
                    }
                }
            }.resume()
        } else {
            self.state = .failure
        }
    }
}

struct RemoteImage: View {

    @StateObject private var loader: RemoteLoader
    let showsSpinner: Bool
    
    init(url: String?, showsSpinner: Bool = true) {
        _loader = StateObject(wrappedValue: RemoteLoader(url: url))
        self.showsSpinner = showsSpinner
    }

    var body: some View {
        foo()
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.1), value: loader.state)
    }

    @ViewBuilder
    private func foo() -> some View {
        switch loader.state {
        case let .success(image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .loading:
            ProgressView()
                .opacity(showsSpinner ? 1 : 0)
        case .failure:
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.system(size: 128, design: .rounded))
                .rotationEffect(.degrees(-45))
                .foregroundColor(.accentColor.opacity(0.3))
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://images.unsplash.com/photo-1614348531618-82d0648c5f16?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80")
    }
}
