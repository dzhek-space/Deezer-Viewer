//
//  BaseCollectionViewCell.swift
//  Deezer Playlists
//
//  Created by Dzhek on 12.04.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    let inset: CGFloat = Constants.Size.inset
    let titleFontSize: CGFloat = Constants.Size.inset
    let subtitleFontSize: CGFloat = (Constants.Size.inset * 0.9).rounded()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            setupViews()
        }
    }
    
    func setupViews() {}
    
}
