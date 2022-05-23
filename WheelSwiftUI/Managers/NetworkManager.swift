//
//  NetworkManager.swift
//  WheelSwiftUI
//
//  Created by Johan David Gonzalez on 2022-05-22.
//

import Foundation
import Combine

enum HTTPMethod:String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

struct ServiceError: Decodable, Error {
    let statusCode:Int
}

protocol NetworkSession: AnyObject {
    func publisher<Response:Decodable>(_ method:HTTPMethod,
                                for url: URL,
                                body: Data?,
                                ofType type:Response.Type) -> AnyPublisher<Response, Error>
}

class NetworkManager:NSObject, URLSessionDelegate {
   
    static let shared = NetworkManager()
    
    private let session: NetworkSession
    
    private override init() {
        self.session = URLSession.shared
        super.init()
    }
    
    func performRequest<Response:Decodable>(_ method:HTTPMethod = .GET,
                                     url:URL,
                                     body: Data?=nil,
                                     ofType type:Response.Type) -> AnyPublisher<Response, Error> {
        return self.session.publisher(method, for: url, body: body, ofType: type)
    }
    
    func performARequest<Response:Decodable>(_ method:HTTPMethod = .GET,
                                            _ endpoint:API.Endpoint,
                                            body: Data?=nil,
                                            ofType type:Response.Type) -> AnyPublisher<Response, Error> {
        let url = URL(string: API.host + endpoint.string)!
        return performRequest(method, url: url, body: body, ofType: type)
    }
}

extension URLSession: NetworkSession {
    
    func publisher<Response:Decodable>(_ method:HTTPMethod = .GET,
                                                        for url: URL,
                                                        body:Data?=nil,
                                                        ofType type:Response.Type) -> AnyPublisher<Response, Error> {
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 60)
        
        self.log(message: "\(method.rawValue) \(url.absoluteString)")
        request.httpMethod = method.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = body

        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    let error = try JSONDecoder().decode(ServiceError.self, from: result.data)
                    
                    throw error
                }
                return result.data
                
            }).decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
  }
}

extension NSObject {
    func log(message: String) {
        print("\(NSStringFromClass(type(of: self))) \(message)")
    }
}
