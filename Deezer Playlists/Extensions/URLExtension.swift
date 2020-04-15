//
//  extURL.swift
//  Deezer Playlists
//
//  Created by Dzhek on 10.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        print(value)
        self = URL(string: value)!
    }
    
}

