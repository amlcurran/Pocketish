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

struct RemoteImage: View {

    private class Loader: ObservableObject {
        var state = LoadState<UIImage>.loading

        init(url: String?) {
            if let foo = url, let parsedURL = URL(string: foo) {
                URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                    if let data = data, data.count > 0, let image = UIImage(data: data) {
                        Thread.sleep(forTimeInterval: 1.0)
                        self.state = .success(image)
                    } else {
                        self.state = .failure
                    }

                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                }.resume()
            } else {
                self.state = .failure
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }

    @StateObject private var loader: Loader

    var body: some View {
        switch loader.state {
        case let .success(image):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .loading:
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 36, design: .rounded))
        case .failure:
            Image(systemName: "photo")
                .font(.system(size: 128, design: .rounded))
                .rotationEffect(.degrees(-45))
                .foregroundColor(Color.accentColor.opacity(0.3))
        }
    }

    init(url: String?) {
        _loader = StateObject(wrappedValue: Loader(url: url))
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://images.unsplash.com/photo-1614348531618-82d0648c5f16?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80")
    }
}
