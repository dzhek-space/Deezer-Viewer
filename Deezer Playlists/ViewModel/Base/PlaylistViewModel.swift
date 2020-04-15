//
//  PlaylistViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 08.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct PlaylistViewModel {

    let id: Int
    let title: String
    let duration: Duration
    let coverUrl: String
    let creatorName: String
    
}

extension PlaylistViewModel: InitiatebleFrom {
    
    init(from item: Playlist) {
        self.id = item.id
        self.title = item.title
        self.duration = Duration(integerLiteral: item.duration, style: .brief)
        self.coverUrl = item.coverUrl
        self.creatorName = item.creatorName
    }
    
}

extension PlaylistViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlaylistViewModel, rhs: PlaylistViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.coverUrl == rhs.coverUrl
    }
    
}
