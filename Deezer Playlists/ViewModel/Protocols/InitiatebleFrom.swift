//
//  InitiatebleFrom.swift
//  Deezer Playlists
//
//  Created by Dzhek on 13.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

protocol InitiatebleFrom {
    
    associatedtype T
    
    init(from item: T)
    
}

