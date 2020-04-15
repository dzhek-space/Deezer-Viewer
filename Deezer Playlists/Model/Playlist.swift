//
//  Playlist.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import Foundation

struct Playlist {
    
    let id: Int
    let title: String
    let duration: Int
    let coverUrl: String
    let creatorName: String
    
}

extension Playlist: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, title, duration, creator
        case coverUrl = "picture_big"
    }
    
    enum CreatorKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        duration = try values.decode(Int.self, forKey: .duration)
        coverUrl = try values.decode(String.self, forKey: .coverUrl)
        
        let creatorValues = try values.nestedContainer(keyedBy: CreatorKeys.self, forKey: .creator)
        creatorName = try creatorValues.decode(String.self, forKey: .name)
    }
    
}
