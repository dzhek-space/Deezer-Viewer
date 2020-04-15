//
//  TemplateSet.swift
//  Deezer Playlists
//
//  Created by Dzhek on 28.01.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct TemplateSet<T> {
    
    let setOfItems: [T]
    let total: Int
    let next: String?
    
    init(setOfItems: [T] = [], total: Int = 0, next: String? = nil) {
        self.setOfItems = setOfItems
        self.total = total
        self.next = next
    }
    
}

extension TemplateSet: Decodable where T: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case total, next
        case setOfItems = "data"
    }
    
}
