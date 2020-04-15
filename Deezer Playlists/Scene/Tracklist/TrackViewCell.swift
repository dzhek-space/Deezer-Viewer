//
//  TrackViewCell.swift
//  Deezer Playlists
//
//  Created by Dzhek on 21.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

final class TrackViewCell: BaseCollectionViewCell {
    
    static var identifier: String = "TracklistCell"
    
    private var titleLabel: BaseLabel! = nil
    private var artistLabel: BaseLabel! = nil
    private var durationLabel: BaseLabel! = nil
    
    func applyModel(_ model: TrackViewModel) {
        titleLabel.text = model.title
        artistLabel.text = "Artist: \(model.artistName)"
        durationLabel.text = model.duration
    }
    
    override func setupViews() {
        super.setupViews()
        
        self.contentView.addShadow(shadowColor: Constants.Color.shadow.ui,
                                   offSet: CGSize(width: 0, height: inset / 6),
                                   opacity: 0.2,
                                   shadowRadius: inset / 6,
                                   cornerRadius: Constants.Size.cornerRadius * 0.5,
                                   corners: [.allCorners],
                                   fillColor: Constants.Color.secondary.ui)
        
        titleLabel = BaseLabel(kind: .title, fontSize: titleFontSize)
        self.contentView.addSubview(titleLabel)
        
        durationLabel = BaseLabel(kind: .subtitle, fontSize: subtitleFontSize)
        self.contentView.addSubview(durationLabel)
        
        artistLabel = BaseLabel(kind: .subtitle, fontSize: subtitleFontSize)
        self.contentView.addSubview(artistLabel)
        
        setupConstraint()
    }
    
}

// MARK: - Configure constraints

extension TrackViewCell {
    
     private func setupConstraint() {
         titleLabel.translatesAutoresizingMaskIntoConstraints = false
         durationLabel.translatesAutoresizingMaskIntoConstraints = false
         artistLabel.translatesAutoresizingMaskIntoConstraints = false
         let views = ["title": titleLabel as UIView,
                      "duration": durationLabel as UIView,
                      "artist": artistLabel as UIView]
         let insetMetrics = ["full": inset,
                             "half": inset / 2,
                             "thirdPart": inset / 3,
                             "double": inset * 2,
                             "quadruple": inset * 4]

         var constraints = [NSLayoutConstraint]()
         constraints.append(contentsOf: NSLayoutConstraint.constraints(
             withVisualFormat: "H:|-full-[title]->=half-[duration(>=double,<=quadruple)]-full-|",
             metrics: insetMetrics, views: views))
         constraints.append(contentsOf: NSLayoutConstraint.constraints(
             withVisualFormat: "H:|-full-[artist]-full-|",
             metrics: insetMetrics, views: views))
         constraints.append(contentsOf: NSLayoutConstraint.constraints(
             withVisualFormat: "V:|-full-[title]-thirdPart-[artist]-full-|",
             metrics: insetMetrics, views: views))
         constraints.append(contentsOf: NSLayoutConstraint.constraints(
             withVisualFormat: "V:|-full-[duration]-thirdPart-[artist]-full-|",
             metrics: insetMetrics, views: views))

         NSLayoutConstraint.activate(constraints)

     }
     
}
