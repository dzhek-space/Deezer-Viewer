//
//  Track.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import Foundation

struct Track {
    
    let id: Int
    let title: String
    let duration: Int
    let artistName: String
    
}

extension Track: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, title, duration, artist
    }
    
    enum ArtistKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        duration = try values.decode(Int.self, forKey: .duration)
        
        let artistValues = try values.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
        artistName = try artistValues.decode(String.self, forKey: .name)
    }
    
}
