//
//  BaseLabel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 10.04.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

class BaseLabel: UILabel {
    
    enum Kind {
        case title
        case subtitle
    }
    
    var height: CGFloat! = nil
    
    convenience init(kind: BaseLabel.Kind,
                     fontSize: CGFloat,
                     numberOfLines: Int = 1,
                     textAlignment: NSTextAlignment = .natural) {
        self.init(frame: .zero)
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
        self.adjustsFontForContentSizeCategory = true
        let textLineHeight: CGFloat
        switch kind {
        case .title:
            font = Constants.Font.headline(size: fontSize).apply
            textLineHeight = Constants.Font.headline(size: fontSize).lineHeight
            textColor = Constants.Color.primaryText.ui
        case .subtitle:
            font = Constants.Font.subheadline(size: fontSize).apply
            textLineHeight = Constants.Font.headline(size: fontSize).lineHeight
            textColor = Constants.Color.gray.ui
        }
        height = CGFloat(numberOfLines) * textLineHeight
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Layout asistants

extension BaseLabel {
    
    func pinToBounds() {
        guard let superView = self.superview
            else { return }
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superView.topAnchor),
            self.bottomAnchor.constraint(lessThanOrEqualTo: superView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superView.trailingAnchor)
        ])
    }
    
}
