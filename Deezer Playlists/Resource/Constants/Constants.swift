//
//  Constant.swift
//  Deezer Playlists
//
//  Created by Dzhek on 23.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

struct Constants {
    
    // Foundation
    // MARK: - Timer
    
    enum Timer: TimeInterval {
        case none = 0
        case base = 0.125
        
        static let zero = { Timer.none.rawValue }()
        static let once = { Timer.base.rawValue }()
        static let double = { Timer.base.rawValue * 2 }()
        static let triple = { Timer.base.rawValue * 3 }()
        static let fivefold = { Timer.base.rawValue * 5 }()
        
    }
    
    
    // UIKit
    // MARK: - Sizes

    enum Size: CGFloat {
        case none = 0
        case base = 18
        
        static let zero = { Size.none.rawValue }()
        static let inset = { Size.base.rawValue }()
        
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let cornerRadius = Size.inset / 1.5
        
    }
    
    // MARK: - Font
    
    enum Font {
        case headline(size: CGFloat)
        case subheadline(size: CGFloat)
        
        var apply: UIFont {
            switch self {
            case .headline(let size): return
                UIFontMetrics(forTextStyle: .headline).scaledFont(for: .boldSystemFont(ofSize: size))
            case .subheadline(let size): return
                UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .boldSystemFont(ofSize: size))
            }
        }
       
        var lineHeight: CGFloat {
            let (nominal, rounded) = (self.apply.lineHeight, self.apply.lineHeight.rounded())
            return nominal < rounded ? nominal + 0.5 : nominal
        }

    }
    
    // MARK: - Color
    
    enum Color: String {
        case primary =  "dynamicPrimary"
        case secondary = "dynamicSecondary"
        case tertiary = "dynamicTertiary"
        case shadow = "shadow"
        case primaryText = "dynamicPrimaryText"
        case gray = "dynamicGray"
        
        var ui: UIColor { UIColor(named: self.rawValue)! }
        var cg: CGColor { UIColor(named: self.rawValue)!.cgColor }
    }
    
    
    // MARK: - Image placeholder
    
    static let placeholderAvailableImage = UIImage(imageLiteralResourceName: "Available")
    static let placeholderUnavailableImage = UIImage(imageLiteralResourceName: "Unavailable")
    
}
