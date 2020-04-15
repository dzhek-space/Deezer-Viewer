//
//  Network.swift
//  Deezer Playlists
//
//  Created by Dzhek on 08.02.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import RxSwift

protocol Network {
    var endpoint: Endpoint { get }
    func request() -> Single<Data>
    
}

extension Network {
    
    private var url: URL {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.path = endpoint.path
        components.query = endpoint.query
        return components.url ?? URL(stringLiteral: "")
    }
    
    func request() -> Single<Data> {
        
        return Single<Data>.create {  singleSubject in
            let requestTask = URLSession.shared.dataTask(with: self.url) { data, response, error in
                    if let error = error, data != nil {
                        singleSubject(.error(error))
                        return
                    }
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(AppError.DeezerError.self, from: data)
                            singleSubject(.error(AppError.Network.badResponse(description: errorResponse.type)))
                        } catch {
                            singleSubject(.success(data))
                        }
                    }
                }
                requestTask.resume()
                return Disposables.create { requestTask.cancel() }
        }
    }
    
}


