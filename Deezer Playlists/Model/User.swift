//
//  User.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import Foundation

struct User {
    
    let id: Int
    let nickname: String
    let avatarUrl: String

}

extension User: Decodable  {
    
    enum CodingKeys: String, CodingKey {
        case id
        case nickname = "name"
        case avatarUrl = "picture_medium"
    }
    
}
