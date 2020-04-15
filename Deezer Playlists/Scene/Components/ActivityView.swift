//
//  ActivityView.swift
//  Deezer Playlists
//
//  Created by Dzhek on 16.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import UIKit

final class ActivityView: UIView {

    enum State {
        case fullscreen
        case bottom
    }
    
    private var indicator: UIActivityIndicatorView! = nil
    private var currentState: ActivityView.State! = nil
    private let inset: CGFloat = Constants.Size.inset
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(within bounds: CGRect, as state: ActivityView.State,_ onComplete: @escaping () -> Void ) {
        currentState = state
        switch state {
        case .fullscreen:
            configureAsFullScreen(bounds)
            UIView.animate(
                withDuration: Constants.Timer.triple,
                delay: Constants.Timer.zero,
                options: .curveEaseOut,
                animations: { self.alpha = 1},
                completion: { _ in onComplete() })
        case .bottom:
            configureAsBottom(bounds)
            UIView.animate(
                withDuration: Constants.Timer.fivefold,
                delay: Constants.Timer.zero,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: .curveEaseOut,
                animations: {
                    self.transform = CGAffineTransform.identity
                    self.alpha = 0.9 },
                completion: { _ in onComplete() })
        }
    }
    
    func hide(_ onComplete: @escaping () -> Void) {
        let completion = { [weak self] in
            self?.indicator.stopAnimating()
            self?.removeFromSuperview()
            onComplete()
        }
        switch currentState {
        case .fullscreen:
            UIView.animate(
                withDuration: Constants.Timer.triple,
                delay: Constants.Timer.zero,
                options: .curveEaseOut,
                animations: { self.alpha = 0 },
                completion: { _ in completion() })
        case .bottom:
            let height = self.frame.height
            UIView.animate(
                withDuration: Constants.Timer.triple,
                delay: Constants.Timer.zero,
                options: .curveEaseOut,
                animations: {
                    self.transform = CGAffineTransform(translationX: 0, y: height)
                    self.alpha = 0 },
                completion: { _ in completion() })
        default:
            break
        }
        
    }


}

// MARK: - Configure layuots & views

extension ActivityView {
    
    private var bottomSafeAreaOffset: CGFloat {
        let window = UIApplication.shared.windows[0]
        let safeAreaFrame = window.safeAreaLayoutGuide.layoutFrame
        return window.frame.maxY - safeAreaFrame.maxY
    }
    
    private func setupSubview() {
        indicator = UIActivityIndicatorView()
        self.addSubview(indicator)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    private func configureAsFullScreen(_ bounds: CGRect) {
        self.frame = bounds
        self.backgroundColor = Constants.Color.secondary.ui
    }
    
    private func configureAsBottom(_ bounds: CGRect) {
        let viewHeight = 4 * inset
        self.frame = CGRect(x: bounds.minX + inset,
                            y: bounds.maxY - viewHeight - inset - bottomSafeAreaOffset,
                            width: bounds.width - inset * 2,
                            height: viewHeight )

        self.backgroundColor = Constants.Color.primary.ui
        self.layer.shadowColor = Constants.Color.shadow.cg
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = inset / 3
        self.layer.cornerRadius = Constants.Size.cornerRadius
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        self.transform = CGAffineTransform(translationX: 0, y: viewHeight * 1.5)
    }
    
}

