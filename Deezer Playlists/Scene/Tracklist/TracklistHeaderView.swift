//
//  TracklistHeaderView.swift
//  Deezer Playlists
//
//  Created by Dzhek on 21.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

final class TracklistHeaderView: BaseHeaderView {
    
    static var identifier: String = "TracklistHeader"
    
    var coverView: UIImageView! = nil
    private var titleLabel: BaseLabel! = nil
    private var creatornameLabel: BaseLabel! = nil
    private var durationLabel: BaseLabel! = nil
    private var labelsStackView: UIStackView! = nil

    override func layoutSubviews() {
        super.layoutSubviews()
        
        redrawSubviews()
    }
    
    func applyModel(_ model: PlaylistViewModel) {
        titleLabel.text = model.title
        creatornameLabel.text = "by: \(model.creatorName)"
        durationLabel.text = model.duration
        if let cachedImage = ImageCache.publicCache.cachedImage(key: model.coverUrl as NSString) {
            coverView.image = cachedImage
        } else {
            coverView.image = Constants.placeholderAvailableImage
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        configureCoverView()
        self.addSubview(coverView)
        titleLabel = BaseLabel(kind: .title, fontSize: titleFontSize)
        creatornameLabel = BaseLabel(kind: .subtitle, fontSize: subtitleFontSize)
        durationLabel = BaseLabel(kind: .subtitle, fontSize: subtitleFontSize)
        configureStackView(with: [titleLabel, creatornameLabel, durationLabel])
        self.addSubview(labelsStackView)
    }
    
}

// MARK: - Configure subviews

extension TracklistHeaderView {
    
    private var сoverSideLength: CGFloat { self.frame.width }
    
    private func configureCoverView() {
        coverView = UIImageView()
        coverView.contentMode = .scaleAspectFit
        coverView.image = Constants.placeholderAvailableImage
        coverView.layer.masksToBounds = true
        coverView.backgroundColor = .clear
    }
    
    private func configureStackView(with labels:  [BaseLabel]) {
        labelsStackView = UIStackView(arrangedSubviews: labels)
        let origin = CGPoint(x: inset,
                              y: сoverSideLength + inset)
        let spacing = inset * 0.5
        let height = labels.reduce(spacing * CGFloat(labels.count - 1)) { $0 + $1.height }
        let size = CGSize(width: сoverSideLength - inset * 2,
                          height: height)
        labelsStackView.frame = CGRect(origin: origin, size: size)
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .center
        labelsStackView.distribution = .fillProportionally
        labelsStackView.spacing = spacing
    }
    
}

// MARK: - Drawing & Animation assistants

extension TracklistHeaderView {
    
    private var sizeFactor: CGFloat {
        coverView.frame.height / сoverSideLength
    }

    private var initialHeight: CGFloat {
        round(сoverSideLength + labelsStackView.bounds.height + inset * 2)
    }

    /// More about easings formulas https://github.com/ai/easings.net (file easingsFunctions.ts)
    private var easeInOutCubicDistortion: CGFloat {
        let easeInOutCubic = sizeFactor < 0.5
            ? 4 * pow(sizeFactor, 3)
            : 1 - pow(2 - 2 * sizeFactor, 3) / 2
        return easeInOutCubic
    }

    private var coverCornerRadius: CGFloat {
        let distortionInset = inset * easeInOutCubicDistortion / 1.5
        let distortionFrameHeight = coverView.frame.height * (1 - easeInOutCubicDistortion)
        let cornerRadius = sizeFactor > 0.52
            ? distortionInset + distortionFrameHeight
            : coverView.frame.height / 2
        return cornerRadius
    }

    private func redrawSubviews() {
        let heightDifference: CGFloat = initialHeight - frame.size.height
        let currentImageSide: CGFloat = сoverSideLength - heightDifference
        let origin = CGPoint(x: heightDifference / 2 ,y: 0)
        let imageSize = CGSize(width: currentImageSide, height: currentImageSide)
        coverView.frame = CGRect(origin: origin, size: imageSize)
        coverView.layer.cornerRadius = coverCornerRadius
        coverView.alpha = easeInOutCubicDistortion

        labelsStackView.transform = CGAffineTransform(translationX: 0, y: -heightDifference)
    }
    
}
