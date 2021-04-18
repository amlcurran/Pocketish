//
//  Debouncer.swift
//  Pocketish
//
//  Created by Alex Curran on 18/04/2021.
//  Copyright © 2021 orgName. All rights reserved.
//

import Foundation
import Combine

class Debouncer<Input> : ObservableObject {
    @Published var debouncedText: Input
    @Published var searchText: Input

    private var subscriptions = Set<AnyCancellable>()

    init(initial: Input) {
        debouncedText = initial
        searchText = initial
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { t in
                self.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}
