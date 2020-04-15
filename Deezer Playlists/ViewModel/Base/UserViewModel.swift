//
//  UserViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 08.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct UserViewModel {
    
    let id: Int
    let nickname: String
    let avatarUrl: String
    var totalPlaylists: String

}

extension UserViewModel {
    
    init(user: User, totalPlaylists: Int) {
        self.id = user.id
        self.nickname = user.nickname
        self.avatarUrl = user.avatarUrl
        self.totalPlaylists = {
            switch totalPlaylists {
                case 1: return "1 playlist"
                case 2...: return "\(totalPlaylists) playlists"
                default: return "no playlists"
            }
        }()
    }
    
}

extension UserViewModel: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
