//
//  UserHeaderView.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

final class UserHeaderView: BaseHeaderView {
    
    static var identifier: String = "UserHeader"
    
    private var avatarView: UIImageView! = nil
    private var usernameLabel: BaseLabel! = nil
    private var totalPlaylistsLabel: BaseLabel! = nil
    private var labelsStackView: UIStackView! = nil
    
    func applyModel(_ model: UserViewModel) {
        usernameLabel.text = model.nickname
        totalPlaylistsLabel.text = model.totalPlaylists
        if let cachedImage = ImageCache.publicCache.cachedImage(key: model.avatarUrl as NSString) {
            avatarView.image = cachedImage
        } else {
            avatarView.image = Constants.placeholderAvailableImage
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        configureAvatarView()
        self.addSubview(avatarView)
        usernameLabel = BaseLabel(kind: .title, fontSize: titleFontSize)
        totalPlaylistsLabel = BaseLabel(kind: .subtitle, fontSize: subtitleFontSize)
        configureStackView(with: [usernameLabel, totalPlaylistsLabel])
        self.addSubview(labelsStackView)
    }
    
}

// MARK: - Configure subviews

extension UserHeaderView {
    
    private var avatarSide: CGFloat { inset * 5 }

    private func configureAvatarView() {
        avatarView = UIImageView(frame: CGRect(x: inset, y: inset, width: inset * 5, height: inset * 5))
        avatarView.image = Constants.placeholderAvailableImage
        avatarView.contentMode = .scaleAspectFit
        avatarView.layer.cornerRadius = avatarSide / 2
        avatarView.layer.masksToBounds = true
        avatarView.backgroundColor = .clear
    }
    
    private func configureStackView(with labels:  [BaseLabel]) {
        labelsStackView = UIStackView(arrangedSubviews: labels)
        let origin = CGPoint(x: inset * 7.5,
                              y: self.bounds.midY - usernameLabel.height)
        let spacing = inset * 0.5
        let height = labels.reduce(spacing * CGFloat(labels.count)) { $0 + $1.height }
        let size = CGSize(width: self.bounds.width - inset * 8,
                          height: height)
        labelsStackView.frame = CGRect(origin: origin, size: size)
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .fillProportionally
        labelsStackView.spacing = spacing
    }

}
