//
//  Resource.swift
//  Deezer Playlists
//
//  Created by Dzhek on 10.02.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import RxSwift

struct Resource<R>: Network {
    let endpoint: Endpoint
    let disposeBag = DisposeBag()
    
    func fetchData() -> Single<Data> {
        request()
    }
    
}

extension Resource where R: Decodable {
    func fetchJson() -> Single<R> {
        request().map { try JSONDecoder().decode(R.self, from: $0) }
    }
    
}
