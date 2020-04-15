//
//  DurationsFormatter.swift
//  Deezer Playlists
//
//  Created by Dzhek on 29.02.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

typealias Duration = String

extension Duration {
    
    enum Style {
        case positional
        case brief
    }
    
    init(integerLiteral value: Int, style: Duration.Style = .positional) {
  
            let formatter = DateComponentsFormatter()
            let interval: TimeInterval
            switch style {
            case .brief:
                formatter.unitsStyle = .brief
                let roundingCondition = value % 60 > 29 && value % 60 != 0
                let rounder = roundingCondition ? (value % 60 - 60) : value % 60
                switch value {
                case 0:
                    self = "Playlist is empty"
                case 1...600 :
                    interval = Double(value)
                    self = "Duration: " + (formatter.string(from: interval) ?? String(value))
                default:
                    interval = Double(value - rounder)
                    self = "Duration: " + (formatter.string(from: interval) ?? String(value))
                }
            case .positional:
                formatter.unitsStyle = .positional
                interval = Double(value)
                self = formatter.string(from: interval) ?? String(value)
            }
    }
    
}
