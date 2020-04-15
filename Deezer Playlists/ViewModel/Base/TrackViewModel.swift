//
//  TrackViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 08.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct TrackViewModel {
    
    let id: Int
    let title: String
    let duration: Duration
    let artistName: String
    
}

extension TrackViewModel: InitiatebleFrom {
    
    init(from item: Track) {
        self.id = item.id
        self.title = item.title
        self.duration = Duration(integerLiteral: item.duration)
        self.artistName = item.artistName
    }
    
}

extension TrackViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TrackViewModel, rhs: TrackViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
