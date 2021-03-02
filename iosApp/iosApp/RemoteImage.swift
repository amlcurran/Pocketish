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
        var data = Data()
        var state = LoadState<Data>.loading

        init(url: String?) {
            if let foo = url, let parsedURL = URL(string: foo) {
                URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                    if let data = data, data.count > 0 {
                        self.state = .success(data)
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
    var loading: Image
    var failure: Image

    var body: some View {
        imageBloop(image: selectImage())
    }

    func imageBloop(image: (image: Image, fill: Bool)) -> some View {
        if image.fill {
            return AnyView(
                image.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        } else {
            return AnyView(
                image.image
                    .font(.system(size: 60))
                    .foregroundColor(.black)
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
        }
    }

    init(url: String?,
         loading: Image = Image(systemName: "photo").renderingMode(.template),
         failure: Image = Image(systemName: "multiply.circle").renderingMode(.template)) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> (Image, fill: Bool) {
        switch loader.state {
        case .loading:
            return (loading, false)
        case .failure:
            return (failure, false)
        case .success(let data):
            if let image = UIImage(data: data) {
                return (Image(uiImage: image), true)
            } else {
                return (failure, false)
            }
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(url: "https://images.unsplash.com/photo-1614348531618-82d0648c5f16?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80")
    }
}
