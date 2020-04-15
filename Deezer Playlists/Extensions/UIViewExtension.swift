//
//  ExtUIView.swift
//  Deezer Playlists
//
//  Created by Dzhek on 09.02.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

extension UIView {
    
    func addShadow(shadowColor: UIColor,
                   offSet: CGSize,
                   opacity: Float,
                   shadowRadius: CGFloat,
                   cornerRadius: CGFloat,
                   corners: UIRectCorner,
                   fillColor: UIColor) {
        
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
        shadowLayer.path = cgPath //2
        shadowLayer.fillColor = fillColor.cgColor //3
        shadowLayer.shadowColor = shadowColor.cgColor //4
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet //5
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
}



