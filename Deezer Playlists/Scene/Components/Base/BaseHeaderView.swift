//
//  BaseHeaderView.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

class BaseHeaderView: UICollectionReusableView {
    
    let inset: CGFloat = Constants.Size.inset
    let halfInset: CGFloat = Constants.Size.inset / 2
    let titleFontSize: CGFloat = (Constants.Size.inset * 1.33).rounded()
    let subtitleFontSize: CGFloat = Constants.Size.inset
    
    override class var layerClass: Swift.AnyClass {
        return CAShapeLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayer()
        setupViews()
        configureShadowPath()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureShadowPath()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            setupLayer()
        }
    }
    
    // MARK: - Configure view
    
    func setupViews() {}

    private func setupLayer() {
        guard let shapeLayer = self.layer as? CAShapeLayer else { return }
        shapeLayer.fillColor = Constants.Color.primary.cg
        shapeLayer.shadowColor = Constants.Color.shadow.cg
        shapeLayer.shadowOffset = CGSize(width: 0,height: 6)
        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowRadius = Constants.Size.inset / 3
    }
    
    private func configureShadowPath() {
        guard let shapeLayer = self.layer as? CAShapeLayer else { return }
        let size = CGSize(width: Constants.Size.inset / 1.5, height: Constants.Size.inset / 1.5)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.allCorners], cornerRadii: size).cgPath
        shapeLayer.path = cgPath
        shapeLayer.shadowPath = cgPath
    }

}
