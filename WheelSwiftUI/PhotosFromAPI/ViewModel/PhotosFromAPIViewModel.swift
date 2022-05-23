//
//  PhotosFromAPIViewModel.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import SwiftUI
import Combine

class PhotosFromAPIViewModel: ObservableObject {
    
    @Published var dogPhotos: [String] = []
    var requests = Set<AnyCancellable>()
    
    func fetchDogPhotos(numberOfPhotos: Int) {
        API.DogPhotos.getAll(number: numberOfPhotos)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {state in
            }, receiveValue: { response in
                self.dogPhotos = response.message
            })
            .store(in: &requests)
    }
}

