//
//  MockViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 10.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct MockViewModel {
    let user = UserViewModel(id: 0,
                             nickname: "John Doe",
                             avatarUrl: "https://cdns-images.dzcdn.net/images/user//500x500-000000-80-0-0.jpg",
                             totalPlaylists: "999 mock")
    
    let playlist = PlaylistViewModel(id: 0,
                                     title: "Mock lulu",
                                     duration: "00:00:00",
                                     coverUrl: "https://cdns-images.dzcdn.net/images/cover//500x500-000000-80-0-0.jpg",
                                     creatorName: "John Doe")
    
    let track = TrackViewModel(id: 0, title: "Mock Track", duration: "00:00:00", artistName: "Jane Doe")
}


// https://e-cdns-images.dzcdn.net/images/user/cb95c50ae277c6659d6a5a259c33a602/500x500-000000-80-0-0.jpg
// https://e-cdns-images.dzcdn.net/images/cover/f0604f1104723a8cb0bd1439bc6f6a30/500x500-000000-80-0-0.jpg
