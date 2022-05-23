//
//  API.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import Foundation
import Combine

//https://dog.ceo/api/breeds/image/random/50

struct API {
    static let host = "https://dog.ceo/api/"
    
}

extension API {
    
    struct IDDTO:Codable {
        let id:Int
    }
    
    enum Endpoint {
        
        case random(number: Int)
        
        var string: String {
            switch self {
                
            case .random(let number):
                return "breeds/image/random/\(number)"
            }
        }
    }
}

extension API {
    struct DogPhotos {
        static func getAll(number: Int) -> AnyPublisher<DogPhotoDTO, Error> {
            return NetworkManager.shared.performARequest(.GET, .random(number: number), ofType: DogPhotoDTO.self)
        }
    }
}
