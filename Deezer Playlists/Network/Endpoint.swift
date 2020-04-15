//
//  Endpoint.swift
//  Deezer Playlists
//
//  Created by Dzhek on 08.02.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

enum Endpoint {
    case user(userId: Int)
    case playlists(userId: Int, query: String? = nil)
    case tracks(playlistId: Int, query: String? = nil)
    case image(fromUrl: String)
    
}


// MARK: - Components of URL

extension Endpoint {

    var scheme: String {
        switch self {
            case .user, .playlists, .tracks, .image: return "https"
        }
    }

    var host: String {
        switch self {
            case .user, .playlists, .tracks: return "api.deezer.com"
            case .image(let imageUrl):
                guard let host = URL(string: imageUrl)?.host else { return "" }
                return host
        }
    }

    var path: String {
        switch self {
            case .user(let userId): return "/user/\(userId)"
            case .playlists(let userId, _): return "/user/\(userId)/playlists"
            case .tracks(let playlistId,_): return "/playlist/\(playlistId)/tracks"
            case .image(let imageUrl):
                guard let path = URL(string: imageUrl)?.path else { return "" }
                return path
        }
    }

    var query: String? {
        switch self {
            case .user, .image: return nil
            case .playlists(_, let nextUrl),.tracks(_, let nextUrl):
                let query: String = URL(string: nextUrl ?? "")?.query ?? "limit=24&index=0"
                return query
        }
    }
    
}
