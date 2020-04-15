//
//  PlaylistViewCell.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

final class PlaylistViewCell: BaseCollectionViewCell {
    
    static var identifier: String = "PlaylistCell"
    
    private var coverView: UIImageView! = nil
    private var titleLabel: BaseLabel! = nil
    private var titleView: UIView! = nil
    
    func applyModel(_ model: PlaylistViewModel) {
        titleLabel.text = model.title
        coverView.image = ImageCache.publicCache.cachedImage(key: model.coverUrl as NSString)
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.backgroundColor = .clear
        configureCoverView()
        self.contentView.addSubview(self.coverView)

        titleLabel = BaseLabel(kind: .title,
                               fontSize: subtitleFontSize,
                               numberOfLines: 2,
                               textAlignment: .center)
        configureTitleView(with: titleLabel)
        self.addSubview(titleView)
        
    }

}

// MARK: - Configure views

extension PlaylistViewCell {
    
    private func configureCoverView() {
        let imageSize = CGSize(width: self.contentView.frame.width,
                               height: self.contentView.frame.width)
        coverView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
        coverView.contentMode = .scaleAspectFit
        coverView.layer.cornerRadius = Constants.Size.cornerRadius
        coverView.layer.masksToBounds = true
        
        addShadowView(with: coverView.frame)
    }
    
    private func addShadowView(with bounds: CGRect) {
        let shadowView = UIView(frame: bounds)
        shadowView.addShadow(shadowColor: Constants.Color.shadow.ui,
                             offSet: CGSize(width: 0, height: inset / 6),
                             opacity: 0.2,
                             shadowRadius: inset / 6,
                             cornerRadius: Constants.Size.cornerRadius,
                             corners: [.allCorners],
                             fillColor: Constants.Color.primary.ui)
        self.contentView.addSubview(shadowView)
    }
    
    private func configureTitleView(with label: BaseLabel) {
        let origin = CGPoint(x: 0, y: self.contentView.frame.width + inset / 3)
        let size = CGSize(width: self.contentView.frame.width, height: label.height + inset / 3)
        titleView = UIView(frame: CGRect(origin: origin, size: size))
        titleView.addSubview(label)
        label.pinToBounds()
    }
}

// MARK: - Animation assistants

extension PlaylistViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                UIView.animate(
                    withDuration: Constants.Timer.once,
                    delay: Constants.Timer.zero,
                    options: .curveEaseOut,
                    animations: {
                        self.coverView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        self.coverView.alpha = 0.9
                })
            case false:
                UIView.animate(
                    withDuration: Constants.Timer.once,
                    delay: Constants.Timer.zero,
                    usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.2,
                    options: .curveEaseOut,
                    animations: {
                        self.coverView.transform = .identity
                        self.coverView.alpha = 1
                })
            }
            
        }
    }

}
